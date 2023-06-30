FROM ubuntu:latest

ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

# Dev conveniences
ARG PKGS="$PKGS make python3-pip"

RUN apt-get update && apt-get install -y $PKGS

CMD ["sleep", "infinity"]
