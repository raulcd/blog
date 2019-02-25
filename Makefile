.PHONY: all build generate-local

REGISTRY := gcr.io/te-chie-la
DOCKER_IMAGE := $(REGISTRY)/raul-blog

build:
	docker build --rm --force-rm -t $(DOCKER_IMAGE) .

generate-local: build
	docker run --rm -it \
		-u $(shell id -u):$(shell id -g) \
		--mount type=bind,source=$(shell pwd),target=/usr/src/app \
		$(DOCKER_IMAGE)


serve: build
	docker run --rm -it \
		-u $(shell id -u):$(shell id -g) \
		--mount type=bind,source=$(shell pwd),target=/usr/src/app \
		-p 1313:1313 \
		$(DOCKER_IMAGE) hugo server --bind=0.0.0.0