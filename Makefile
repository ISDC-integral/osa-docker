SHELL := /bin/bash

OSA_PLATFORM?=CentOS_7.8.2003_x86_64
OSA_VERSION?=$(shell curl https://www.isdc.unige.ch/~savchenk/gitlab-ci/integral/build/osa-build-tarball/cross-platform/latest/latest/osa-version-ref.txt)
ISDC_REF_CAT_VERSION?=42.0

IMAGE?=integralsw/osa:${OSA_VERSION}-refcat-${ISDC_REF_CAT_VERSION}-$(shell git describe --always --tag)
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

# full analysis test

get-test-ic:
	mkdir -pv current-ic 
	[ -a current-ic/done ] || curl https://www.isdc.unige.ch/~savchenk/ic/osa112beta.tgz | tar xvzf - --strip-components 1 -C current-ic
	touch current-ic/done


get-test-data:
	mkdir -pv data
	INTEGRAL_DATA=$(PWD)/data bash <(curl https://raw.githubusercontent.com/volodymyrss/dda-ddosadm/master/download_data.sh) 1972 197200240010 || true

test-slow: get-test-ic get-test-data build
	REP_BASE_PROD=$(PWD)/data CURRENT_IC=$(PWD)/current-ic \
		      ./osa-docker.sh make -C /tests run-slow
