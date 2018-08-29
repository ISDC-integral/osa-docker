IMAGE?=integralsw/osa:11.0
IMAGE_LATEST?=integralsw/osa:latest
#IMAGE?=cdcihn.isdc.unige.ch:443/integral-osa:11.0

push: build
	docker push $(IMAGE) 
	docker push $(IMAGE_LATEST) 

build: Dockerfile
	docker build . -t $(IMAGE) 
	docker build . -t $(IMAGE_LATEST) 

