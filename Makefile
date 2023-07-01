.PHONY:=default base-dev python-dev infra-dev aws-dev azure-dev node-dev dev-tools

# This is the final product that we care about.
#
# We could use stages and copy binaries, but this is easy to manage.
# It allows going into any dir easily and just running "make"
# to update that layer.
#
# Or, just run "make here to build it all, using the cache
# to skip layers that didn't change.
default: dev-tools

base-dev:
	cd ./docker-images/base-dev && make

python-dev: base-dev
	cd ./docker-images/python-dev && make

infra-dev: python-dev
	cd ./docker-images/infra-dev && make

aws-dev: infra-dev
	cd ./docker-images/aws-dev && make

azure-dev: aws-dev
	cd ./docker-images/azure-dev && make

node-dev: azure-dev
	cd ./docker-images/node-dev && make

dotnet-dev: node-dev
	cd ./docker-images/dotnet-dev && make

dev-tools: dotnet-dev
	cd ./docker-images/dev-tools && make
