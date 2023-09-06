# GOAL

Create a docker image for running things such as:
- AWS and Azure CLI tools
- Terraform
- Terragrunt
- OpenSSH Server
- Mitmproxy

# Directories

- ./bin
  Contains the command, "dev", which runs the container.
  Run this by itself to see the various options it supports (e.g. proxy).

- ./tools/mfa-with-aws-cli
  This contains code to produce temporary (self-expiring) credentials based on the
  aws cli user that runs the script (generate-aws-cli-mfa-credentials.sh).
  There is also a script showing how to decrypt a symmetrically encrypted version
  of the credentials file produced.

# Setup

Required:
- Set up ~/home_dev and support passwordless SSH for the dev
  user whose home dir in the contianer, /home/dev,
  will bind to ~/home_dev in the host.

Example
- mkdir -p ~/home_dev/.ssh
- cat ~/.ssh/id_rsa.pub >> ~/home_dev/.ssh/authorized_keys
- chmod 0700 ~/home_dev/.ssh
- chmod 0600 ~/home_dev/.ssh/authorized_keys
- Example SSH config
```
# ~/.ssh/config
Host dev
	HostName 127.0.0.1
	User dev
	Port 2222
```
I recommend:
- For git
  - Putting repos under ~/home_dev/git
  - Sym-Linking to ~/home_dev/git from ~/git
- Adding the bin dir of this repo to $PATH


Optional:
- Configure the machine for Nvidia Container Toolkit
  Example: https://github.com/pwyoung/computer-setup/blob/master/home/bin/setup-popos-computer.sh
