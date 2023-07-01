FROM node-dev:latest

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

USER root

# Default shell
SHELL ["/bin/bash", "-c"]

# https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-2204
RUN apt-get update && \
    apt-get install -y dotnet-sdk-7.0

# Mono: warning: apparently this lacks some features of the "real" dotnet version
#
# Is not tested on Ubuntu 22.04, only 20.04... per
# https://www.mono-project.com/download/stable/#download-lin
#
# https://www.mono-project.com/docs/getting-started/mono-basics/
# apt-get install mono-complete
# mono --version
# Mono JIT compiler version 6.8.0.105 (Debian 6.8.0.105+dfsg-3.2 Wed Jun 30 05:34:49 UTC 2021)
#
#RUN sudo apt install ca-certificates gnupg
#RUN sudo gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
#RUN echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
#RUN sudo apt-get update -y
#RUN apt-get -y install mono-complete

# CLEANUP

RUN rm -rf /tmp/* && apt autoremove -y

CMD ["sleep", "infinity"]
