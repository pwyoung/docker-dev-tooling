# Use a Makefile to document dependencies and ordering of
# expected uses of the shell script.
#
# This makefile runs the code using a virtual environment.
#
# As a rule, "make" should 'just work'

# Directory containing this makefile. Includes trailing /
MAKEFILE_PATH=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))

.PHONY:=default FORCE all clean clean-all build test

PROJECT=aws-bedrock
VENV_PARENT:=$(HOME)/virtual-environments
RUN:=. $(VENV_PARENT)/$(PROJECT)/bin/activate && $(MAKEFILE_PATH)/run

default: all

# Noop dependency. Reliable/idiomatic way to force the target to run.
FORCE:

clean-all: FORCE
	$(RUN) --clean-all

clean: FORCE
	$(RUN) --clean

venv: FORCE
	[ -e "$(VENV_PARENT)/$(PROJECT)" ] || mkdir -p "$(VENV_PARENT)" && cd "$(VENV_PARENT)" && python3 -m venv $(PROJECT)

build: venv
	$(RUN) --build

test: build
	$(RUN) --test

all: test
