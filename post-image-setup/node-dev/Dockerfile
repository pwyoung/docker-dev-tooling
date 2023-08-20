FROM azure-dev:latest

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive


# Default shell
SHELL ["/bin/bash", "-c"]

# Ensure Nodejs packages are not installed
RUN apt-get purge nodejs &&\
  rm -rf /etc/apt/sources.list.d/nodesource.list

# For posterity, do not do this. This gives Node.js v12.x
#RUN apt-get update && apt-get install -y nodejs

# Gives Node.js v18.17.x which Angular does not officially support now
#   and causes our code to throw errors.
# https://github.com/nodesource/distributions#debinstall
#RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
#  sudo apt-get install -y nodejs

# Angular-cli
#RUN cd /root && mkdir ./test && cd ./test && npm install @angular/cli # Local test
#RUN npm install @angular/cli -g # Global

# YARN
#RUN npm install -g yarn

################################################################################
# "nodedev" user
################################################################################

# Remember, ARGs are not secure
ARG NODEDEVUSER=nodedev
ARG NODEDEVPW=nodedev
ARG NODEDEVHOME=/home/nodedev
ARG NODEDEVUID=1001
ARG NODEDEVSHELL=/usr/bin/bash

# Create a non-root user (with group 'wheel')
RUN useradd -s $NODEDEVSHELL --uid $NODEDEVUID --create-home --home-dir $NODEDEVHOME $NODEDEVUSER \
        && chown -R $NODEDEVUSER:$NODEDEVUSER $NODEDEVHOME \
        && echo -e "$NODEDEVUSER:$NODEDEVPW" | chpasswd \
        && usermod -aG wheel $NODEDEVUSER

USER $NODEDEVUSER
WORKDIR $NODEDEVHOME

# https://github.com/nvm-sh/nvm#install--update-script
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

# Run using "HERE" syntax since it preserves the environment after sourcing the NVM setup script.
RUN <<EOF

# Use nvm immediately
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# Angular currently "actively-supports" this version of NODE
#   https://angular.io/guide/versions
nvm install v18.10.0

EOF

# Don't rely on ~/.bashrc since docker run seems to ignore it, no matter what args are passed
RUN echo 'export "NVM_DIR=${HOME}/.nvm" && . "$NVM_DIR/nvm.sh"' >> "${HOME}/.bash_profile"

################################################################################
# "dev" user
################################################################################
# NOTE: The dev user's setup will have to run the above manually
# This is because /home/dev will be a shared folder when 'devc' is run

# CLEANUP
USER root

RUN rm -rf /tmp/* && apt autoremove -y

# Become nodedev again
USER $NODEDEVUSER
WORKDIR $NODEDEVHOME


CMD ["sleep", "infinity"]
