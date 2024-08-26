FROM nvcr.io/nvidia/nemo:24.05.01

# https://docs.nvidia.com/deeplearning/frameworks/support-matrix/index.html
# Confirmed: OS base is Ubuntu 22.04.2 via:
#   docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 -it --rm nvcr.io/nvidia/pytorch:23.08-py3 bash -c 'cat /etc/os-release' | grep VERSION
# See
#   https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html
#   https://github.com/NVIDIA/NeMo/blob/main/Dockerfile

ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

################################################################################
# OS Packages
################################################################################

# Install packages
# Split up due to timeout issues building this via WSL2
RUN apt-get update && \
  apt-get install -y \
  wget curl unzip sudo jq git groff software-properties-common graphviz openssh-server \
  pass less tree emacs-nox iputils-ping dnsutils whois htop psmisc bash-completion time net-tools

################################################################################
# SSH server
################################################################################

RUN mkdir -p /run/sshd

################################################################################
# "dev" user
################################################################################

# Remember, ARGs are not secure
ARG DEVUSER=dev
ARG DEVPW=dev
ARG DEVHOME=/home/dev
ARG DEVSHELL=/usr/bin/bash
# DEVUID will be set as a build arg to match the host user ID
ARG DEVUID

# Remember some parameters
ENV DEVUSER=$DEVUSER
ENV DEVHOME=$DEVHOME
ENV DEVUID=$DEVUID

# Create the 'wheel' group
RUN groupadd wheel

# Create a non-root user (with group 'wheel')
RUN useradd -s $DEVSHELL --uid $DEVUID --create-home --home-dir $DEVHOME $DEVUSER \
        && chown -R $DEVUSER:$DEVUSER $DEVHOME \
        && echo -e "$DEVUSER:$DEVPW" | chpasswd \
        && usermod -aG wheel $DEVUSER

# Let any user in the group 'wheel' run sudo without a password
RUN echo '%wheel         ALL = (ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
  chmod 0440 /etc/sudoers.d/wheel

################################################################################
# User CLI conveniences
################################################################################

#   These would normally be aliases
RUN echo 'git log --oneline --graph' > /usr/local/bin/gl && \
  echo 'git status $@' > /usr/local/bin/gs && \
  echo 'git branch' > /usr/local/bin/gb && \
  echo 'emacs -nw $@' > /usr/local/bin/e && \
  echo 'rm -rf ./*~ ./*# 2>/dev/null' > /usr/local/bin/c && \
  echo 'ls --color=auto -ltr $@' > /usr/local/bin/l && \
  echo 'echo "$PWD" > ~/.marked_path' > /usr/local/bin/m && \
  echo 'pstree -GapT' > /usr/local/bin/pt && \
  chmod 0755 /usr/local/bin/{gl,gs,gb,e,c,l,m,pt}

################################################################################
# PYTHON
################################################################################

ARG PKGS="make python3-pip python3-venv python-is-python3"

RUN apt-get update && apt-get install -y $PKGS

################################################################################
# INFRASTRUCTURE
################################################################################

# Add Terraform
#   https://www.terraform.io/downloads
RUN cd /tmp && \
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
  apt-get update && apt-get install terraform

# Add Terragrunt
# https://github.com/gruntwork-io/terragrunt/releases
RUN cd /tmp && \
  wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.53.2/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
  chmod 0755 /usr/local/bin/terragrunt && \
  terragrunt --version

# AWS-Nuke: TODO
#   https://github.com/rebuy-de/aws-nuke/releases

# MAAS
# RUN apt-add-repository ppa:maas/3.4-next && apt update && apt-get -y install maas

################################################################################
# MICROSOFT: Azure, DotNet
################################################################################

# AZURE CLI
#   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
RUN apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
  apt-get update -y && apt-get install -y azure-cli && \
  az --version | grep azure-cli

# DOTNET-7
#   https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-2204
#RUN apt-get update && \
#    apt-get install -y dotnet-sdk-7.0

# DOTNET-8
#   https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-install?pivots=os-linux-ubuntu-2204&tabs=dotnet8#install-the-sdk
RUN apt-get update && \
    apt-get install -y dotnet-sdk-8.0


################################################################################
# WEBAPP DEV
################################################################################

# MITMPROXY
#   https://docs.mitmproxy.org/stable/
#   https://hub.docker.com/r/mitmproxy/mitmproxy/
RUN mkdir -p /tmp/mitm && \
    cd /tmp/mitm && \
    wget https://downloads.mitmproxy.org/10.0.0/mitmproxy-10.0.0-linux.tar.gz && \
    tar xvzf mitmproxy-*-linux.tar.gz && \
    cd /tmp/mitm && \
    chmod 755 /tmp/mitm/mitm* && \
    chown $DEVUID:$DEVUID /tmp/mitm/mitm* && \
    mv /tmp/mitm/mitm* /usr/local/bin

################################################################################
# Network Speed testing
################################################################################

RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash \
    && sudo apt update && sudo apt-get install speedtest && sudo apt-get install -y lsof

################################################################################
# K8S
################################################################################

# Per https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management

RUN sudo apt-get update && \
  sudo apt-get install -y apt-transport-https ca-certificates curl && \
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update && \
  sudo apt-get install -y kubectl kubeadm kubecolor kubetail && \
  mkdir -p /root/helm && \
  cd /root/helm && \
  wget https://get.helm.sh/helm-v3.13.1-linux-amd64.tar.gz && \
  tar -zxvf helm-v3.13.1-linux-amd64.tar.gz && \
  mv -f /root/helm/linux-amd64/helm /usr/local/bin && \
  chmod 755 /usr/local/bin/helm

################################################################################

RUN sudo apt-get update && sudo apt-get install -y libsndfile1 ffmpeg

# TODO: move up
RUN python -m pip install --upgrade pip

################################################################################
# Make it easy to run services
################################################################################

# SSH
COPY ./docker-scripts/start-ssh.sh /start-ssh.sh
RUN chmod 0755 /start-ssh.sh

# Jupyter
COPY ./docker-scripts/start-jupyter.sh /start-jupyter.sh
RUN chmod 0755 /start-jupyter.sh
COPY ./docker-scripts/stop-jupyter.sh /stop-jupyter.sh
RUN chmod 0755 /stop-jupyter.sh

# Simple Start command
COPY ./docker-scripts/start.sh /start.sh
RUN chmod 0755 /start.sh

################################################################################
# AWS
################################################################################

# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions
RUN mkdir -p ~/AWS && cd ~/AWS && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    sudo ./aws/install

################################################################################
# ANSIBLE
################################################################################
RUN sudo apt update &&\
  sudo apt-get install -y software-properties-common &&\
  sudo add-apt-repository --yes --update ppa:ansible/ansible

# RUN sudo apt install -y ansible


################################################################################
# CLEANUP
################################################################################

RUN rm -rf /tmp/*

USER $DEVUSER
WORKDIR $DEVHOME

CMD ["sleep", "infinity"]
