.PHONY:=all clean build test review-image

DOCKER_TAG:=latest
DOCKER_IMAGE:=base-dev:$(DOCKER_TAG)

# Docker build args
#
# Assign the image name (repo:tag)
BARGS:=-t $(DOCKER_IMAGE)
# Force build to occur
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
#   Check user
TC:=egrep '^dev:' /etc/passwd
TC:=$(TC) && ls -ld /home/dev
#
TC:=$(TC) && command -v ssh


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
