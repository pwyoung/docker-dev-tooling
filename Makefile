.PHONY:=all build clean docker-image test-image test login review-image run-container setup-aws setup-node test-only

# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SHELL:=/bin/bash

DOCKER_TAG:=latest
DOCKER_IMAGE:=dev-tools:$(DOCKER_TAG)

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
BARGS:=$(BARGS) --build-arg DEVUID=$(HOST_UID)

# "docker run" args
#
# Interactive TTY
RARGS:=-t -i
# Remove container when it stops running
RARGS:=$(RARGS) --rm

# Test the image
TC:=whoami
TC:=$(TC) && az --version | grep azure-cli
TC:=$(TC) && terraform --version
TC:=$(TC) && terragrunt --version
TC:=$(TC) && dotnet --info | head -3

# Test the final container
TC2:=whoami
TC2:=$(TC2) && . ~/virtual-environments/bedrock/venv/bin/activate && aws --version
TC2:=$(TC2) && mitmproxy --version
TC2:=$(TC2) && node --version
TC2:=$(TC2) && npm --version
TC2:=$(TC2) && yes | tr 'y' "\n" | ng version
TC2:=$(TC)

all: test

clean:
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

docker-image:
	$(info Build Docker Image)
	DOCKER_BUILDKIT=1 docker build $(BARGS) .

test-image: docker-image
	$(info Running test scripts)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "$(TC)"

run-container: test-image
	$(MAKEFILE_PATH)/bin/dev -s

setup-aws: run-container
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/Makefile dev:/tmp/
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/run dev:/tmp/
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/test-bedrock-via-boto.py dev:/tmp/
	$(MAKEFILE_PATH)/bin/dev -c "cd /tmp && make"

setup-node: run-container
	docker cp $(MAKEFILE_PATH)post-image-setup/node-dev/setup-node.sh dev:/tmp/
	$(MAKEFILE_PATH)/bin/dev -c "bash -x /tmp/setup-node.sh"

test: | setup-aws setup-node
	$(MAKEFILE_PATH)/bin/dev -c "$(TC2)"

login: build
        $(info Logging into container)
        docker run $(RARGS) $(DOCKER_IMAGE) bash -l

review-image:
	echo "Review Docker Image"
	docker inspect $(DOCKER_IMAGE)
	docker history $(DOCKER_IMAGE)
	docker images | head -2

test-only:
	$(MAKEFILE_PATH)/bin/dev -c "$(TC2)"
