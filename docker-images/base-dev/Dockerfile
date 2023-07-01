FROM ubuntu:latest

ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

################################################################################
# OS Packages
################################################################################

# Important
ARG PKGS="wget curl unzip sudo jq groff git software-properties-common graphviz openssh-server"

# Convenient
ARG PKGS2="pass less tree emacs-nox iputils-ping dnsutils whois htop psmisc bash-completion time"

# Install packages
RUN apt-get update && apt-get install -y $PKGS $PKGS2

################################################################################
# SSH server
#   Don't assume we want to run it. Do that externally.
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

WORKDIR /

CMD ["sleep", "infinity"]
