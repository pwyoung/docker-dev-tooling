.PHONY:=all clean build test

# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

# "dev" command
DEV=$(realpath $(MAKEFILE_PATH)/../../bin/dev)

# setup script
SCRIPT=$(realpath $(MAKEFILE_PATH)/setup-aws.sh)

SHELL:=/bin/bash


# Test command
TC:=aws --version

all: test

clean:
	$(info Clean)

build:
	$(info Build $(DEV))
	$(DEV) -s
	docker cp $(SCRIPT) dev:/tmp
	dev -c "bash -x /tmp/setup-aws.sh | tee /tmp/setup-aws.sh.out"

test: build
	$(info Running test)
	dev -c "aws --version"

