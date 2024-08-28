# GOAL
#  Create a docker container that works like a dev VM
#  so that we don't have to hear "it works for me" but not you.
#  Use a host directory as the HOME directory of the dev user

# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SHELL:=/bin/bash

DOCKER_TAG:=latest
DOCKER_IMAGE:=dev-tools:$(DOCKER_TAG)

# "docker build" args
#
# Assign the image name (repo:tag)
BARGS:=-t $(DOCKER_IMAGE)
#
# Force (re)build to occur (slow, but always a clean slate)
#BARGS:=$(BARGS) --no-cache
#
# Be compatible with Intel/AMD even if on ARM (e.g. Apple Silicon)
# Use "DOCKER_DEFAULT_PLATFORM=linux/amd64" instead
#BARGS:=$(BARGS) --platform=linux/amd64

# Match the USERID so to avoid complants,
# e.g. that ~/.ssh/config has the wrong owner
HOST_UID:=$(shell id -u)
#
# For podman,
# BUILDAH_FORMAT=docker
#BARGS:=$(BARGS) --format=docker
#
BARGS:=$(BARGS) --build-arg DEVUID=$(HOST_UID)
BARGS:=$(BARGS) --build-arg DOCKER_BASE_IMAGE=$(DOCKER_BASE_IMAGE)

# "docker run" args
#
# Interactive TTY
RARGS:=-t -i
# Remove container when it stops running
RARGS:=$(RARGS) --rm

.PHONY:=all
all: test

.PHONY:=FORCE
FORCE:

.PHONY:=clean
clean: FORCE
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

.PHONY:=docker-image
docker-image: FORCE
	$(info Build Docker Image)
	BUILDAH_FORMAT=docker DOCKER_BUILDKIT=1 docker build $(BARGS) .

.PHONY:=test
test: docker-image
	$(info Running test scripts)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "aws --version"
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "az --version"
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "terraform --version"
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "terragrunt --version"
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "dotnet --info | head -3"
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "kubectl version --client"
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "helm version"
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "mitmproxy --version"


.PHONY:=run-container
run-container: docker-image
	$(MAKEFILE_PATH)/bin/dev -s || echo "error starting container"

.PHONY:=setup-node
setup-node: run-container
	echo "Setting up node 1"
	$(MAKEFILE_PATH)/bin/dev -c "bash -x /setup-node.sh"
	echo "Setting up node X"

################################################################################
# Manually invoked make targets (for dev/test)
################################################################################

review-image: FORCE
	echo "Review Docker Image"
	docker inspect $(DOCKER_IMAGE)
	docker history $(DOCKER_IMAGE)
	docker images | head -2

login: FORCE
	$(info Logging into container)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -l

