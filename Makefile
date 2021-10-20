SHELL := /bin/bash
REGISTRY := ghcr.io
IMAGE_NAME := wahlfeld/ci-runner:latest
DS_VERSION := 1.36.4

.PHONY: .phony
.DEFAULT_GOAL := test-local

.deps-mac:
	curl -L -o ds.zip https://downloads.dockerslim.com/releases/$(DS_VERSION)/dist_mac.zip && \
	unzip ds.zip && \
	mv dist_mac/docker-slim /usr/local/bin/ && \
	mv dist_mac/docker-slim-sensor /usr/local/bin/
	rm -r dist_mac
	rm ds.zip
	touch .deps-mac

.deps-linux:
	curl -L -o ds.tar.gz https://downloads.dockerslim.com/releases/$(DS_VERSION)/dist_linux.tar.gz && \
    tar -xvf ds.tar.gz && \
    mv dist_linux/docker-slim /usr/local/bin/ && \
    mv dist_linux/docker-slim-sensor /usr/local/bin/

.build-local: .deps-mac
	docker-slim build . \
	--dockerfile Dockerfile \
	--tag $(REGISTRY)/$(IMAGE_NAME) \
	--http-probe-off \
	--exec 'sh test.sh' \
	--include-path '/usr/lib/python3.9/site-packages/certifi/cacert.pem' \
	--include-path '/usr/lib/python3.9/site-packages/pip/_vendor/certifi/cacert.pem' \
	--include-path '/etc/ssl/' && \
	touch .build-local

build-ci: .phony .deps-linux
	docker-slim --in-container build . \
	--dockerfile Dockerfile \
	--tag $(REGISTRY)/$(IMAGE_NAME) \
	--http-probe-off \
	--exec 'sh test.sh' \
	--include-path '/usr/lib/python3.9/site-packages/certifi/cacert.pem' \
	--include-path '/usr/lib/python3.9/site-packages/pip/_vendor/certifi/cacert.pem' \
	--include-path '/etc/ssl/'

test-local: .phony .build-local
	docker run $(REGISTRY)/$(IMAGE_NAME) sh test.sh

test-ci: .phony build-ci
	docker run $(REGISTRY)/$(IMAGE_NAME) sh test.sh

push-ci: .phony build-ci
	docker push $(REGISTRY)/$(IMAGE_NAME)

clean: .phony
	rm .deps-mac .deps-linux .build-local slim.report.json
