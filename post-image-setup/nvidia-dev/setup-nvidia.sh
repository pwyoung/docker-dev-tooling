#!/usr/bin/env bash

set -e

################################################################################
# NVIDIA dev setup
################################################################################

# "ngc" cli
#   Per https://ngc.nvidia.com/setup/installers/cli
mkdir -p ~/nvidia

cd ~/nvidia

if [ ! -e ngc-cli/ngc ]; then
    if [ ! -e ngccli_linux.zip ]; then
        wget --content-disposition https://api.ngc.nvidia.com/v2/resources/nvidia/ngc-apps/ngc_cli/versions/3.27.0/files/ngccli_linux.zip -O ngccli_linux.zip
    fi

    rm -rf ./ngc-cli
    unzip ngccli_linux.zip

    find ngc-cli/ -type f -exec md5sum {} + | LC_ALL=C sort | md5sum -c ngc-cli.md5 | grep sha256sum ngccli_linux.zip | grep acb956eb1043bb9ae0962338d28a2abbb524c63377dbf7ca67ae13458df5a227

    chmod u+x ngc-cli/ngc
fi

~/nvidia/ngc-cli/ngc --version
