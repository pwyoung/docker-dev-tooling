FROM base-dev:latest

ARG TZ=UTC
ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

ARG PKGS="make python3-pip python3-venv python-is-python3"

RUN apt-get update && apt-get install -y $PKGS

CMD ["sleep", "infinity"]
