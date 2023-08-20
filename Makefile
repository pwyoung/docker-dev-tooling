.PHONY:=all clean build test review-image post-image-setup setup-aws

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

# Test command
#TC:=aws --version
TC:=whoami
TC:=$(TC) && az --version | grep azure-cli
TC:=$(TC) && terraform --version
TC:=$(TC) && terragrunt --version
#TC:=$(TC) && sudo su - nodedev -c 'node --version'
#TC:=$(TC) && sudo su - nodedev -c 'npm --version'
TC:=$(TC) && dotnet --info | head -3
#TC:=$(TC) && mitmproxy --version

all: post-image-setup

clean:
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

build:
	$(info Build Docker Image)
	DOCKER_BUILDKIT=1 docker build $(BARGS) .

# Test the image
test: build
	$(info Running test scripts)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "$(TC)"

setup-aws: test
	$(MAKEFILE_PATH)/bin/dev -s
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/Makefile dev:/tmp/
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/run dev:/tmp/
	docker cp $(MAKEFILE_PATH)post-image-setup/aws-dev/test-bedrock-via-boto.py dev:/tmp/
	$(MAKEFILE_PATH)/bin/dev -c "cd /tmp && make"

post-image-setup: | setup-aws

login: build
        $(info Logging into container)
        docker run $(RARGS) $(DOCKER_IMAGE) bash -l

review-image:
	echo "Review Docker Image"
	docker inspect $(DOCKER_IMAGE)
	docker history $(DOCKER_IMAGE)
	docker images | head -2
