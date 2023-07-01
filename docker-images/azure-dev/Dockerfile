FROM aws-dev:latest

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

# Default shell
SHELL ["/bin/bash", "-c"]

USER  root

# Azure-CLI
#  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
RUN apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
  apt-get update -y && apt-get install -y azure-cli && \
  az --version | grep azure-cli

# CLEANUP
RUN rm -rf /tmp/*

CMD ["sleep", "infinity"]
