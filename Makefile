.PHONY:=all build clean docker-image test-image test login review-image run-container setup-aws setup-node test-only

# Notes:
#   This makes it easy to build and test the dev container.
#   Here are some examples of how work with this.
#     If only the Dockerfile changed:
#       "make docker-image"
#     If only one of the post-setup steps, such as nvidia setup, changed:
#       "make setup-nvidia"
#     Then run "dev -l" to test manually


# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SHELL:=/bin/bash

DOCKER_TAG:=latest
DOCKER_IMAGE:=dev-tools:$(DOCKER_TAG)

#DOCKER_BASE_IMAGE:=ubuntu:22.04
#DOCKER_BASE_IMAGE:=nvcr.io/nvidia/pytorch:23.08-py3
DOCKER_BASE_IMAGE:=nvcr.io/nvidia/nemo:23.06

# "docker build" args
#
# Assign the image name (repo:tag)
BARGS:=-t $(DOCKER_IMAGE)
# Force (re)build to occur
#BARGS:=$(BARGS) --no-cache
#
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

# Test the image
TC:=whoami
TC:=$(TC) && aws --version
TC:=$(TC) && az --version | grep azure-cli
TC:=$(TC) && terraform --version
TC:=$(TC) && terragrunt --version
TC:=$(TC) && dotnet --info | head -3
TC:=$(TC) && kubectl version --client
TC:=$(TC) && helm version

# Test the final container
TC2:=whoami
TC2:=$(TC2) && . ~/virtual-environments/bedrock/venv/bin/activate && aws --version
TC2:=$(TC2) && mitmproxy --version
TC2:=$(TC2) && node --version
TC2:=$(TC2) && npm --version
TC2:=$(TC2) && yes | tr 'y' "\n" | ng version
TC2:=$(TC2) && ~/nvidia/ngc-cli/ngc --version
TC2:=$(TC)

all: test

FORCE:

clean: FORCE
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

# Speed up rebuilds
get-base-image: FORCE
	docker pull $(DOCKER_BASE_IMAGE)

docker-image: get-base-image
	$(info Build Docker Image)
	BUILDAH_FORMAT=docker DOCKER_BUILDKIT=1 docker build $(BARGS) .

test-image: docker-image
	$(info Running test scripts)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "$(TC)"

run-container: test-image
	$(MAKEFILE_PATH)/bin/dev -s

################################################################################
# post-container creation setup
#   This is for files that must live in ~dev (i.e. ~/home_dev)
################################################################################

setup-aws: run-container
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/Makefile dev:/tmp/
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/run dev:/tmp/
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/test-bedrock-via-boto.py dev:/tmp/
	$(MAKEFILE_PATH)/bin/dev -c "cd /tmp && make"

setup-node: run-container
	docker cp $(MAKEFILE_PATH)post-image-setup/node-dev/setup-node.sh dev:/tmp/
	$(MAKEFILE_PATH)/bin/dev -c "bash -x /tmp/setup-node.sh"

setup-nvidia: run-container
	docker cp $(MAKEFILE_PATH)post-image-setup/nvidia-dev/Makefile dev:/tmp
	docker cp $(MAKEFILE_PATH)post-image-setup/nvidia-dev/run dev:/tmp
	$(MAKEFILE_PATH)/bin/dev -c "cd /tmp && make"

test: | setup-aws setup-node setup-nvidia
	$(MAKEFILE_PATH)/bin/dev -c "$(TC2)"


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

test-only: FORCE
	$(MAKEFILE_PATH)/bin/dev -c "$(TC)"
	$(MAKEFILE_PATH)/bin/dev -c "$(TC2)"
