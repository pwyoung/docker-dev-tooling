FROM python-dev:latest

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

# Default shell
SHELL ["/bin/bash", "-c"]

# Add Terraform
#   https://www.terraform.io/downloads
RUN cd /tmp && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && apt-get install terraform

# Add Terragrunt
# https://github.com/gruntwork-io/terragrunt/releases
RUN cd /tmp && \
  wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.48.4/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
  chmod 0755 /usr/local/bin/terragrunt && \
  terragrunt --version

# MAAS
RUN apt-add-repository ppa:maas/3.4-next && apt update && apt-get -y install maas

# CLEANUP
RUN rm -rf /tmp/*

CMD ["sleep", "infinity"]
