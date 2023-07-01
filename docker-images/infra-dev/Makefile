.PHONY:=all clean build deps test review-image

# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SHELL:=/bin/bash

DOCKER_TAG:=latest
DOCKER_IMAGE:=infra-dev:$(DOCKER_TAG)

# "docker build" args
#
# Assign the image name (repo:tag)
BARGS:=-t $(DOCKER_IMAGE)
# Force (re)build to occur
#BARGS:=$(BARGS) --no-cache

# "docker run" args
#
# Interactive TTY
RARGS:=-t -i
# Remove container when it stops running
RARGS:=$(RARGS) --rm

# Test command
TC:=terraform --version
TC:=$(TC) && terragrunt --version

all: test

clean:
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

build:
	$(info Build Docker Image)
	DOCKER_BUILDKIT=1 docker build $(BARGS) .

test: build
	$(info Running test scripts)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "$(TC)"

review-image:
	echo "Review Docker Image"
	docker inspect $(DOCKER_IMAGE)
	docker history $(DOCKER_IMAGE)
	docker images | head -2
