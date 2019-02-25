REGISTRY := gcr.io/te-chie-la
DOCKER_IMAGE := $(REGISTRY)/raul-blog

all: release

build:
	docker build --rm --force-rm -t $(DOCKER_IMAGE) .

generate-local: build
	docker run --rm -it \
		--mount type=bind,source=$(shell pwd),target=/usr/src/app \
		$(DOCKER_IMAGE)


.PHONY: all build generate-local