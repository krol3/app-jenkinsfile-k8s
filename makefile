.PHONY: all build 

all: help

help:
	@echo -e "build:              Build the image"
	@echo -e "run:                Run the container"
	@echo -e "delete:             Delete the container"

build:
	docker build -t krol/app-go:dev .

test:
	docker run -it --rm krol/app-go:dev /bin/sh

push:
	docker push krol/app-go:dev

run-backend:
	docker network create sample-nt
    $(shell docker run --rm -p 8080:8080 --name backend --network sample-nt krol/app-go:dev)

run-frontend:
	$(shell docker run --rm -p 8085:8085 --network sample-nt krol/app-go:dev ./app -frontend=true -backend-service=http://backend:8080 -port=8085)