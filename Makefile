IMAGE?=integralsw/osa:11.0
IMAGE_LATEST?=integralsw/osa:latest

push: build
	docker push $(IMAGE) 
	docker push $(IMAGE_LATEST) 

build: Dockerfile
	docker build . -t $(IMAGE) 
	docker build . -t $(IMAGE_LATEST) 

pull:
	docker pull $(IMAGE) 
	docker pull $(IMAGE_LATEST) 
