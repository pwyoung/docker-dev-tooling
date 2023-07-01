FROM dotnet-dev:latest

# Remember, ARGs are not secure
#ARG DEVUSER=dev
#ARG DEVHOME=/home/dev

# Set timezone and avoid being prompted for it
ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

# Default shell
SHELL ["/bin/bash", "-c"]

# Conveniences
ARG PKGS="net-tools"

# Install packages
RUN apt-get update && apt-get install -y $PKGS

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

# CLEANUP
RUN rm -rf /tmp/*

USER $DEVUSER

WORKDIR $DEVHOME

CMD ["sleep", "infinity"]
