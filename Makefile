OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/savchenk/osa-build-tarball/CentOS_7.5.1804_x86_64/latest/latest/osa-version-ref.txt)

IMAGE?=integralsw/osa:${OSA_VERSION}
IMAGE_LATEST?=integralsw/osa:latest

push: build
	docker push $(IMAGE) 
	docker push $(IMAGE_LATEST) 

build: Dockerfile
	docker build --build-arg OSA_VERSION=${OSA_VERSION} . -t $(IMAGE) 
	docker build --build-arg OSA_VERSION=${OSA_VERSION} . -t $(IMAGE_LATEST) 

pull:
	docker pull $(IMAGE) 
	docker pull $(IMAGE_LATEST) 
