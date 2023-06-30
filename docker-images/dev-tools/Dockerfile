FROM python-dev:latest

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

# Default shell
SHELL ["/bin/bash", "-c"]

ARG PKGS="wget curl unzip sudo unzip less jq groff git tree emacs-nox software-properties-common graphviz dnsutils whois"
RUN apt-get update && apt-get install -y $PKGS

# Remember, ARGs are not secure
ARG DEVUSER=dev
ARG DEVPW=dev
ARG DEVHOME=/home/dev
ARG DEVUID=1000

# Create the 'wheel' group
RUN groupadd wheel

# Create a non-root user (with group 'wheel')
RUN useradd --uid $DEVUID --create-home --home-dir $DEVHOME $DEVUSER \
        && chown -R $DEVUSER:$DEVUSER $DEVHOME \
        && echo -e "$DEVUSER:$DEVPW" | chpasswd \
        && usermod -aG wheel $DEVUSER

# Let any user in the group 'wheel' run sudo without a password
RUN echo '%wheel         ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
  chmod 0440 /etc/sudoers.d/wheel


# Get aws-shell (comes with AWS CLI v1)
RUN pip install aws-shell

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
RUN cd /tmp && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"        -o "awscliv2.zip" && \
  unzip ./awscliv2.zip && \
  /tmp/aws/install -b /root && \
  mv /root/aws /usr/local/bin/aws-v2 && \
  mv /usr/local/bin/aws /usr/local/bin/aws-v1 && \
  ln -s /usr/local/bin/aws-v2 /usr/local/bin/aws && \
  echo 'Sanity check installed tools' && \
  /usr/local/bin/aws-v1 --version && \
  /usr/local/bin/aws-v2 --version && \
  /usr/local/bin/aws-shell --help

# Add AWS SAM CLI
# https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html
# The above URL redirects, so use "wget" (not curl)
RUN mkdir -p /tmp/aws-sam-cli && \
  cd /tmp/aws-sam-cli && \
  wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -O "aws-sam-cli-linux-x86_64.zip" && \
  unzip aws-sam-cli-linux-x86_64.zip && \
  /tmp/aws-sam-cli/install && \
  echo 'Sanity check installed tools' && \
  /usr/local/bin/sam --version

# Add Terraform and Terragrunt
#   https://www.terraform.io/downloads
RUN cd /tmp && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && sudo apt-get install terraform
  #apt-get update && sudo apt-get install terraform=1.1.4

RUN cd /tmp && \
  wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.37.1/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
  chmod 0755 /usr/local/bin/terragrunt && \
  terragrunt --version

# Conveniences
#   These would normally be aliases
RUN echo 'git log --oneline --graph' > /usr/local/bin/gl && \
  echo 'git status $@' > /usr/local/bin/gs && \
  echo 'git branch' > /usr/local/bin/gb && \
  echo 'emacs -nw $@' > /usr/local/bin/e && \
  echo 'rm -rf ./*~ ./*# 2>/dev/null' > /usr/local/bin/c && \
  echo 'ls --color=auto -ltr $@' > /usr/local/bin/l && \
  echo 'echo "$PWD" > ~/.marked_path' > /usr/local/bin/m && \
  chmod 0755 /usr/local/bin/{gl,gs,gb,e,c,l,m}

# Azure-CLI
#  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
RUN apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
  apt-get update -y && apt-get install -y azure-cli && \
  az --version | grep azure-cli

# SSH server
RUN sudo apt install -y openssh-server && \
  sudo mkdir -p /run/sshd

# CLEANUP
RUN rm -rf /tmp/*

USER $DEVUSER

WORKDIR $DEVHOME

CMD ["sleep", "infinity"]
