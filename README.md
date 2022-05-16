# GOAL

Create a docker image for running things such as:
- AWS CLI tools
- Terraform
- Terragrunt

# Directories

- ./docker-images/aws-cli-shell-docker-image
  This creates a docker image which can be used to run
    - aws cli commands
    - aws shell
    - aws sam commands
    - Whatever else we add to the Dockerfile

- ./docker-images/python-dev
  This creates a docker image based on Ubuntu, configured for Python3 development.
  This is used by aws-cli-shell-docker-image/Dockerfile

- ./tools/mfa-with-aws-cli
  This contains code to produce temporary (self-expiring) credentials based on the
  aws cli user that runs the script (generate-aws-cli-mfa-credentials.sh).
  There is also a script showing how to decrypt a symmetrically encrypted version
  of the credentials file produced.
