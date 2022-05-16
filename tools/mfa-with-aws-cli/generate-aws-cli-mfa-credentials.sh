#!/usr/bin/env bash

# Exit immediately on error
set -e


################################################################################
# Parameters
################################################################################

# Overwrite "credentials" in this directory
DOT_AWS_DIR=~/MFA_DOT_AWS

# Cache results that don't change often.
# Choose a directory per user
TMP_DIR=~/tmp/aws-personal

# If the session file is older than this, then regenerate it
SESSION_FILE_MAX_AGE=5400 # 1.5 hours (in seconds)

SESSION_DURATION="129600"
#SESSION_DURATION="129600" # Max allowed is 36 hours
#SESSION_DURATION="86400" # One day
#SESSION_DURATION="7200" # 2 hours

# Change this, for example, if we need to specify a profile
AWS_CMD='aws --profile default'

################################################################################
# Calculated values
################################################################################

GET_USER_FILE="$TMP_DIR/get-user.txt"
LIST_MFA_DEVICES_FILE="$TMP_DIR/list-mfa-devices.txt"
GET_SESSION_FILE="$TMP_DIR/get-session.txt"

# AWS credentials file
AWS_CRED_FILE="$DOT_AWS_DIR/credentials"

# Terraform credentials file
TF_CRED_FILE="$DOT_AWS_DIR/secrets.tf"

# 'gpg -a' adds .asc to the filename
#GPG_AWS_CRED_FILE="${AWS_CRED_FILE}.asc"

# File with one-line, the passphrase
GPG_PASS_FILE=~/.private/gpg_pass_file.txt

################################################################################
# Usage
################################################################################

show_usage(){
    cat <<EOF
Usage: $0 [-d] -c <MFA_CURRENT_CODE>

Args with their long-forms
        -c|--mfa-current-code: enter the current MFA code
        -h|--help: show this help

Example: Given that the Authenticator app shows '123456' for the aws user configured to run '$AWS_CMD'
$0 -c 123456

This will do the following:
- determine the IAM USER from the credentials specified by '$AWS_CMD'
- fetch the MFA device's serial number for the IAM USER
- Create a new AWS credentials file, $AWS_CRED_FILE
- Create an encrypted version of the AWS credentials file, ${AWS_CRED_FILE}.asc using the contents of ${GPG_PASS_FILE}

The new file will have the same permissions as the given IAM USER.
The credentials will expire in $SESSION_DURATION seconds.

EOF
}

################################################################################

get_user_file(){
    echo "Getting $GET_USER_FILE"
    $AWS_CMD iam get-user > $GET_USER_FILE
}

# Get the IAM user and AWS account id.
# Re-use the cached values if available
get_iam_user_and_account() {
    if [ -f $GET_USER_FILE ]; then
        echo "$GET_USER_FILE exists"
    else
        get_user_file
    fi

    if cat $GET_USER_FILE | jq -r .User.UserName >/dev/null; then
        echo "$GET_USER_FILE seems valid"
    else
        echo "File is not valid, regenerating it"
        get_user_file
        if cat $GET_USER_FILE | jq -r .User.UserName >/dev/null; then
            echo "$GET_USER_FILE seems valid now"
        else
            echo "File is not valid, EXIT"
            exit 1
        fi
    fi

    IAM_USER=$(cat $GET_USER_FILE | jq -r .User.UserName)
    AWS_ACCOUNT_ID=$(cat $GET_USER_FILE | jq -r .User.Arn | cut -d ':' -f 5)
}

get_list_mfa_devices_file() {
    echo "Getting $LIST_MFA_DEVICES_FILE"
    $AWS_CMD iam list-mfa-devices --user-name "$IAM_USER" > $LIST_MFA_DEVICES_FILE
}

# Get the MFA serial number for this IAM user
# Re-use the cached values if available
get_mfa_serial_number() {
    if [ -f $LIST_MFA_DEVICES_FILE ]; then
        echo "$LIST_MFA_DEVICES_FILE exists"
    else
        get_list_mfa_devices_file
    fi

    if cat $LIST_MFA_DEVICES_FILE | jq -r .MFADevices[0].SerialNumber >/dev/null; then
        echo "$LIST_MFA_DEVICES_FILE seems valid"
    else
        echo "File is not valid, regenerating it"
        get_list_mfa_devices_file
        if cat $LIST_MFA_DEVICES_FILE | jq -r .MFADevices[0].SerialNumber >/dev/null; then
            echo "$LIST_MFA_DEVICES_FILE seems valid"
        else
            echo "File is not valid, EXIT"
            exit 1
        fi
    fi

    MFA_SN=$(cat $LIST_MFA_DEVICES_FILE | jq -r .MFADevices[0].SerialNumber)
}

get_session_file() {
    # https://awscli.amazonaws.com/v2/documentation/api/latest/reference/sts/get-session-token.html
    ARGS="--serial-number $MFA_SN --token-code $MFA_CODE"

    ARGS+=" --duration-seconds $SESSION_DURATION"

    echo "Getting $GET_SESSION_FILE"
    $AWS_CMD sts get-session-token $ARGS > $GET_SESSION_FILE
}

get_aws_keys_and_session_token() {
    FILE_AGE=$SESSION_FILE_MAX_AGE

    # File age (in seconds)
    if [ -f $GET_SESSION_FILE ]; then
        FILE_AGE=$(($(date +%s) - $(stat -c '%Y' "$GET_SESSION_FILE")))
    fi

    if [ $FILE_AGE -lt $SESSION_FILE_MAX_AGE ]; then
        echo "$GET_SESSION_FILE exists"
    else
        get_session_file
    fi

    # Test that the file is valid. If not, fetch it again.
    if cat $GET_SESSION_FILE | jq -r .Credentials.AccessKeyId >/dev/null; then
        echo "$GET_SESSION_FILE seems valid"
    else
        echo "File is not valid, regenerating it"
        get_session_file
        if cat $GET_SESSION_FILE | jq -r .Credentials.AccessKeyId >/dev/null; then
            echo "File is not valid, EXIT"
            exit 1
        fi
    fi

    ACCESS_KEY_ID=$(cat $GET_SESSION_FILE | jq -r .Credentials.AccessKeyId)
    SECRET_ACCESS_KEY=$(cat $GET_SESSION_FILE | jq -r .Credentials.SecretAccessKey)
    SESSION_TOKEN=$(cat $GET_SESSION_FILE | jq -r .Credentials.SessionToken)
    EXPIRATION=$(cat $GET_SESSION_FILE | jq -r .Credentials.Expiration)

}

# overwrite the credentials files
recreate_credentials_files() {

    cat <<EOF > $AWS_CRED_FILE
[mfa]
# https://console.aws.amazon.com/iam/home#/users/${IAM_USER}
aws_access_key_id = ${ACCESS_KEY_ID}
aws_secret_access_key = ${SECRET_ACCESS_KEY}

# The session is needed since the access key doesn't exist (in the normal place AWS looks for it without this)
# In testing, without the quotes, the session value was not assigned properly
aws_session_token = "${SESSION_TOKEN}"
EOF


        cat <<EOF > $TF_CRED_FILE
variable "aws_access_key" {
  default = "${ACCESS_KEY_ID}"
}

variable "aws_secret_key" {
  default = "${SECRET_ACCESS_KEY}"
}

variable "aws_session_token" {
  default = "${SESSION_TOKEN}"
}

EOF



}

recreate_gpg_credentials_file() {
    # Encrypt the credentials file using a password stored in another file and apply ASCII Armour
    cat $GPG_PASS_FILE | gpg --batch --yes --passphrase-fd 0 -a --symmetric --cipher-algo AES256 $AWS_CRED_FILE

    # test decryption
    cat $GPG_PASS_FILE | gpg  --batch --yes --passphrase-fd 0 -d ${AWS_CRED_FILE}.asc > $AWS_CRED_FILE.test-decryption
    if ! diff $AWS_CRED_FILE.test-decryption $AWS_CRED_FILE; then
        echo "Error, the test decryption failed. This should be impossible"
        exit 1
    fi
    rm $AWS_CRED_FILE.test-decryption
}

summary() {
    echo "SUCCESS. Summary of results..."
    echo "The new temporary credentials file is at ${AWS_CRED_FILE}"
    echo "The credentials file has been encrypted and ASCII armored (e.g. for sending over email)"
    echo "The passphase used is in $GPG_PASS_FILE"
    echo "The resulting encrypted and ASCII armored file is at ${AWS_CRED_FILE}.asc"
    echo "The resulting encrypted and ASCII armored contents are"
    cat ${AWS_CRED_FILE}.asc

    echo "On another computer, put the passphrase and credentials in local files and run something like:"
    echo "  cat ~/.private/gpg_pass_file.txt | gpg  --batch --yes --passphrase-fd 0 -d ~/credentials.asc > ~/.aws/credentials"
}

# Main program
run_main() {
    mkdir -p $TMP_DIR

    get_iam_user_and_account

    get_mfa_serial_number

    get_aws_keys_and_session_token

    recreate_credentials_files

    recreate_gpg_credentials_file

    summary
}

delete_tmp_dir() {
    rm -rf $TMP_DIR
}

if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

# This holds bad data after failures. So, just remove it.
delete_tmp_dir

# read args
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -c|--mfa-current-code)
            shift
            MFA_CODE=$1
            shift
            run_main
            ;;
        -h|--help)
            show_usage
            shift
            ;;
        *)
            echo "unknown option '$1'"
            show_usage
            exit 1
            ;;
    esac
done
