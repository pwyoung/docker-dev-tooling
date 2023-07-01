# GOAL

Create a docker image for running things such as:
- AWS and Azure CLI tools
- Terraform
- Terragrunt
- OpenSSH Server

# Directories

- ./docker-images/python-dev
  This creates a docker image based on Ubuntu, configured for Python3 development.
  This is the basis for the dev-tools image

- ./docker-images/dev-tools
  This creates a docker image which can be used to run the additional tools beyond Python

- ./tools/mfa-with-aws-cli
  This contains code to produce temporary (self-expiring) credentials based on the
  aws cli user that runs the script (generate-aws-cli-mfa-credentials.sh).
  There is also a script showing how to decrypt a symmetrically encrypted version
  of the credentials file produced.

- ./bin
  Contains commands that can be used to run the container.
  See ./bin/README.adoc or the individual scripts for details.
