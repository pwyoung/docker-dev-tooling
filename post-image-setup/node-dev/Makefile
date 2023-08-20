.PHONY:=all clean build test review-image

# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SHELL:=/bin/bash

DOCKER_TAG:=latest
DOCKER_IMAGE:=node-dev:$(DOCKER_TAG)

# "docker build" args
#
# Assign the image name (repo:tag)
BARGS:=-t $(DOCKER_IMAGE)
# Force (re)build to occur
#BARGS:=$(BARGS) --no-cache
#

# "docker run" args
#
# Interactive TTY
RARGS:=-t -i
# Remove container when it stops running
RARGS:=$(RARGS) --rm

# Test command
#TC:=. ~/.nvm-setup && node --version
#TC:=$(TC) . ~/.nvm-setup && npm --version
TC:=node --version
TC:=$(TC) && npm --version

all: test

clean:
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

build:
	$(info Build Docker Image)
	DOCKER_BUILDKIT=1 docker build $(BARGS) .

test: build
	$(info Running test scripts)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -l -c "$(TC)"

login: build
	$(info Logging into container)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -l

review-image:
	echo "Review Docker Image"
	docker inspect $(DOCKER_IMAGE)
	docker history $(DOCKER_IMAGE)
	docker images | head -2
