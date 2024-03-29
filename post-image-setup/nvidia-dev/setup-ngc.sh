#!/usr/bin/env bash

set -e

ngc_cli() {
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
}

ngc_cli_config() {
    cat <<EOF
# Generate API token
#   https://ngc.nvidia.com/setup
#   ngc config set
# Check access
#   ngc config current
# Docs
#   https://docs.ngc.nvidia.com/cli/index.html
#   https://docs.nvidia.com/base-command-platform/user-guide/index.html#terms-and-concepts
# TODO/TEST:
#   Fails:
#     Most commmands...
#       ngc org subscription --org ny9dz9ua1hz5 info
#       ngc registry csp info
#       ngc ace list # ACE is a cluster or availability zone.
#   Succeeds:
#     https://docs.ngc.nvidia.com/cli/cmd_registry.html
#       ngc registry image list
#       ngc registry chart list
#       ngc registry collection list
#       ngc registry model list
#       ngc registry resource list


# Triton Server
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/tritonserver
#   docker pull nvcr.io/nvidia/tritonserver:23.08-py3
#   docker pull nvcr.io/nvidia/tritonserver:23.08-py3-sdk # Has client libs and model analyzer
EOF
}

ngc_cli
ngc_cli_config
