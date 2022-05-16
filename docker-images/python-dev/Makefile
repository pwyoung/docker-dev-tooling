.PHONY:=all clean docker-image

DOCKER_TAG:=latest
DOCKER_IMAGE:=python-dev:$(DOCKER_TAG)

# Docker build args
#
# Assign the image name (repo:tag)
DARGS:=-t $(DOCKER_IMAGE)
# Force build to occur
#DARGS:=$(DARGS) --no-cache

all: docker-image

clean:
	$(info Clean)
	docker rmi $(DOCKER_IMAGE) || true

docker-image:
	$(info Build Docker Image)
	DOCKER_BUILDKIT=1 docker build $(DARGS) .
