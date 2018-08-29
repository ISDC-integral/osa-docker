#IMAGE?=integralsw/osa:11.0
IMAGE?=integralsw/osa:latest
#IMAGE?=cdcihn.isdc.unige.ch:443/integral-osa:11.0

push: build
	docker push $(IMAGE) 

build: Dockerfile
	docker build . -t $(IMAGE) 

