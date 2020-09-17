OSA_PLATFORM?=CentOS_7.7.1908_x86_64
OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/$(OSA_PLATFORM)/latest/latest/osa-version-ref.txt)
ISDC_REF_CAT_VERSION?=43.0

IMAGE?=integralsw/osa:${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}
IMAGE_LATEST?=integralsw/osa:latest

push: build
	docker push $(IMAGE) 
	docker push $(IMAGE_LATEST) 

build: Dockerfile
	docker build --build-arg isdc_ref_cat_version=${ISDC_REF_CAT_VERSION} --build-arg OSA_VERSION=${OSA_VERSION} --build-arg OSA_PLATFORM=$(OSA_PLATFORM) . -t $(IMAGE) 
	docker tag $(IMAGE) $(IMAGE_LATEST) 

pull:
	docker pull $(IMAGE) 
	docker pull $(IMAGE_LATEST) 

test: build
	docker run --user $(shell id -u) $(IMAGE) bash -c 'cd /tests; ls -ltor; make'
