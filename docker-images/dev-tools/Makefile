.PHONY:=all clean build deps test

# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

SHELL:=/bin/bash

DOCKER_TAG:=latest
DOCKER_IMAGE:=dev-tools:$(DOCKER_TAG)

# Match the UID of the current user
# This is for the aws-shell which wants to write to ~/.aws/
DEVUID:=$$UID
# Support mapping the host .aws dir to the container
DEVHOME:=/home/dev

# Support using a different AWS credential directory
ifndef DOT_AWS
override DOT_AWS:=$(HOME)/.aws
endif

# "docker build" args
#
# Assign the image name (repo:tag)
BARGS:=-t $(DOCKER_IMAGE)
# Force (re)build to occur
#BARGS:=$(BARGS) --no-cache
#
BARGS:=$(BARGS) --build-arg DEVUID=$(DEVUID)
BARGS:=$(BARGS) --build-arg DEVHOME=$(DEVHOME)

# "docker run" args
#
# Interactive TTY
RARGS:=-t -i
# Remove container when it stops running
RARGS:=$(RARGS) --rm
# Share AWS credentials
RARGS:=$(RARGS) -v $(DOT_AWS):$(DEVHOME)/.aws

# Test command
TC:=aws --version
TC:=$(TC) && aws-v2 --version
#TC:=$(TC) && aws-shell --help
TC:=$(TC) && sam --version
TC:=$(TC) && terraform --version
TC:=$(TC) && terragrunt --version
TC:=$(TC) && git --version

all: test

clean:
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

deps:
	$(info create python-env)
	cd ../python-dev/ && make

build: deps
	$(info Build Docker Image)
	DOCKER_BUILDKIT=1 docker build $(BARGS) .
	echo "Review Docker Image"
	docker inspect $(DOCKER_IMAGE)
	docker history $(DOCKER_IMAGE)
	docker images | head -2

test: build
	$(info Running test scripts)
	docker run $(RARGS) $(DOCKER_IMAGE) bash -c "$(TC)"
