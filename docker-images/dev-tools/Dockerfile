FROM python-dev:latest

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

# Default shell
SHELL ["/bin/bash", "-c"]

# Remember, ARGs are not secure
ARG DEVUSER=dev
ARG DEVPW=dev
ARG DEVHOME=/home/dev
ARG DEVUID=1000

# Create a non-root user with root/sudo privileges
RUN useradd --uid $DEVUID --create-home --home-dir $DEVHOME $DEVUSER \
        && chown -R $DEVUSER:$DEVUSER $DEVHOME \
        && echo -e "$DEVUSER:$DEVPW" | chpasswd \
        && usermod -aG sudo $DEVUSER

ENV PKGS="wget curl unzip sudo unzip less jq groff"
RUN apt-get update && apt-get install -y $PKGS

# Get aws-shell (comes with AWS CLI v1)
RUN pip install aws-shell

# Add AWS CLI to v2 ALONGSIDE AWS CLI v1
# NOTE: aws-shell expects AWS-CLI-V1. It fails with V2 (without some hacking). Since aws-shell is beta, avoid hacking.
#
RUN cd /tmp && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip" && \
  unzip ./awscliv2.zip && \
  /tmp/aws/install -b /root && \
  mv /root/aws /usr/local/bin/aws-v2 && \
  mv /usr/local/bin/aws /usr/local/bin/aws-v1 && \
  ln -s /usr/local/bin/aws-v1 /usr/local/bin/aws && \
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
ENV PKGS2="emacs-nox software-properties-common"
RUN apt-get update && apt-get install -y $PKGS2
RUN cd /tmp && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && sudo apt-get install terraform

RUN cd /tmp && \
  wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.37.1/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
  chmod 0755 /usr/local/bin/terragrunt

# Conveniences
RUN echo 'git log --oneline --graph' > /usr/local/bin/gl && \
  echo 'git status $@' > /usr/local/bin/gs && \
  echo 'emacs -nw $@' > /usr/local/bin/e && \
  echo 'ls --color=auto -ltr $@' > /usr/local/bin/l && \
  echo 'echo "$PWD" > ~/.marked_path' > /usr/local/bin/m && \
  chmod +x /usr/local/bin/{gl,gs,e,l,m} && \
  chmod +x /etc/profile.d/z

# CLEANUP
RUN rm -rf /tmp/*

USER $DEVUSER

WORKDIR $DEVHOME

CMD ["sleep", "infinity"]
