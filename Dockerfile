#ARG DOCKER_BASE_IMAGE=ubuntu:22.04
#ARG DOCKER_BASE_IMAGE=nvcr.io/nvidia/pytorch:23.08-py3
ARG DOCKER_BASE_IMAGE=nvcr.io/nvidia/nemo:23.06
FROM $DOCKER_BASE_IMAGE

# https://docs.nvidia.com/deeplearning/frameworks/support-matrix/index.html
# Confirmed: OS base is Ubuntu 22.04.2 via:
#   docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 -it --rm nvcr.io/nvidia/pytorch:23.08-py3 bash -c 'cat /etc/os-release' | grep VERSION
# Details
#   https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html

ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

################################################################################
# OS Packages
################################################################################

# Important
ARG PKGS="wget curl unzip sudo jq groff git software-properties-common graphviz openssh-server"

# Convenient
ARG PKGS2="pass less tree emacs-nox iputils-ping dnsutils whois htop psmisc bash-completion time net-tools"

# Install packages
RUN apt-get update && apt-get install -y $PKGS $PKGS2

################################################################################
# SSH server
#   Don't run it. Do that externally.
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
  wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.48.4/terragrunt_linux_amd64 -O /usr/local/bin/terragrunt && \
  chmod 0755 /usr/local/bin/terragrunt && \
  terragrunt --version

# MAAS
RUN apt-add-repository ppa:maas/3.4-next && apt update && apt-get -y install maas

################################################################################
# MICROSOFT: Azure, DotNet
################################################################################

#  https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
RUN apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list && \
  apt-get update -y && apt-get install -y azure-cli && \
  az --version | grep azure-cli

# https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-2204
RUN apt-get update && \
    apt-get install -y dotnet-sdk-7.0

# Mono: warning: apparently this lacks some features of the "real" dotnet version
# Is not tested on Ubuntu 22.04, only 20.04... per
# https://www.mono-project.com/download/stable/#download-lin
# Skipping this.

################################################################################
# WEBAPP DEV
################################################################################

# MITMPROXY
#   https://docs.mitmproxy.org/stable/
#   https://hub.docker.com/r/mitmproxy/mitmproxy/
RUN mkdir -p /tmp/mitm && \
    cd /tmp/mitm && \
    wget https://downloads.mitmproxy.org/10.0.0/mitmproxy-10.0.0-linux.tar.gz && \
    tar xvzf mitmproxy-*-linux.tar.gz

RUN cd /tmp/mitm && \
    chmod 755 /tmp/mitm/mitm* && \
    chown $DEVUID:$DEVUID /tmp/mitm/mitm* && \
    mv /tmp/mitm/mitm* /usr/local/bin

################################################################################
# Speed testing
################################################################################
RUN curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash \
    && sudo apt update \
    && sudo apt-get install speedtest

RUN sudo apt-get install -y lsof


################################################################################
# K8S
################################################################################

# Per https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management

RUN sudo apt-get update && \
  sudo apt-get install -y apt-transport-https ca-certificates curl && \
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update && \
  sudo apt-get install -y kubectl kubeadm kubecolor kubetail

################################################################################
# NVIDIA:NEMO
#   https://docs.nvidia.com/deeplearning/frameworks/pytorch-release-notes/rel-23-08.html#rel-23-08
################################################################################

RUN sudo apt-get update && sudo apt-get install -y libsndfile1 ffmpeg

# TODO: move up
RUN python -m pip install --upgrade pip

#
# STOPPED HERE
#

# CUDA
#RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
#dpkg -i cuda-keyring_1.1-1_all.deb
#apt-get update -y
# image: 12.1.105-1
# release notes: 12.2.1
#apt-get install cuda=12.2.1 -y

################################################################################
# Make it easy to run (many or all) services
################################################################################

#   SSH
RUN echo 'sudo service ssh start &> /tmp/start.sh.out' > /start-ssh.sh && \
  chmod 0755 /start-ssh.sh

#  Jupyter
RUN echo 'nohup jupyter lab --no-browser --allow-root --ip=0.0.0.0 --NotebookApp.token="" --NotebookApp.password="" &> /tmp/jupyter.log &' > /start-jupyter.sh && \
  chmod 0755 /start-jupyter.sh

#  Simple Start command
RUN echo '/start-ssh.sh && /start-jupyter.sh && sleep infinity' > /start.sh && \
  chmod 0755 /start.sh

################################################################################
# CLEANUP
################################################################################

RUN rm -rf /tmp/*

USER $DEVUSER
WORKDIR $DEVHOME

CMD ["sleep", "infinity"]

