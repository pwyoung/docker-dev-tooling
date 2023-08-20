#!/usr/bin/env bash


if ! node --version | grep 18.10.0; then

    # Ensure Nodejs packages are not installed
    sudo apt-get purge nodejs
    sudo rm -rf /etc/apt/sources.list.d/nodesource.list

    # Avoid this; it gives Node.js v12.x
    # apt-get update && apt-get install -y nodejs

    # Gives Node.js v18.17.x which Angular does not officially support now
    #   and causes our code to throw errors.
    # https://github.com/nodesource/distributions#debinstall
    # curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - &&\
    # sudo apt-get install -y nodejs

    # https://github.com/nvm-sh/nvm#install--update-script
    cd ~/
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

    # Use nvm immediately
    export NVM_DIR=${HOME}/.nvm && . "$NVM_DIR/nvm.sh"

    # Angular currently "actively-supports" this version of NODE
    # per https://angular.io/guide/versions
    nvm install v18.10.0

    # Don't rely on ~/.bashrc since docker run seems to ignore it, no matter what args are passed
    if ! grep NVM_DIR "${HOME}/.bash_profile"; then
        echo 'export "NVM_DIR=${HOME}/.nvm" && . "$NVM_DIR/nvm.sh"' >> "${HOME}/.bash_profile"
    fi
fi

# Update NPM
#npm install -g npm@latest
if ! npm -g ls npm@9.8.1; then
    npm install -g npm@9.8.1
fi

# Angular-cli
if ! npm -g ls @angular/cli; then
    npm install -g @angular/cli
fi

# YARN
if ! npm -g ls yarn; then
    npm install -g yarn
fi

