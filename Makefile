PROJECT=app-go
COMMIT=$(shell git rev-parse HEAD)
BRANCH_=$(BRANCH_NAME)
PREFIX_REP=krol

ifndef BRANCH_NAME
	BRANCH_=$(shell git rev-parse --abbrev-ref HEAD)
endif

SLASH:= /
DASH:= -
BRANCH_GIT:=$(subst $(SLASH),$(DASH),$(BRANCH_))

.PHONY: all build

all: help

help:
	@echo -e "build:              Build the image"
	@echo -e "run:                Run the container"

build:
	@echo "Build container: $(PREFIX_REP)/${PROJECT}:$(BRANCH_GIT)-$(COMMIT)"
	docker build -t $(PREFIX_REP)/${PROJECT}:$(BRANCH_GIT)-$(COMMIT) .

shell:
	docker run --rm -it $(PREFIX_REP)/${PROJECT}:$(BRANCH_GIT)-$(COMMIT) sh

test:
	docker run -it --rm $(PREFIX_REP)/${PROJECT}:$(BRANCH_GIT)-$(COMMIT) go test

run:
	docker run --rm -p 8085:8080 $(PREFIX_REP)/${PROJECT}:$(BRANCH_GIT)-$(COMMIT)

push:
	docker push $(PREFIX_REP)/${PROJECT}:$(BRANCH_GIT)-$(COMMIT)

jenkins-install:
	helm install --namespace ci --name j-v1 -f k8s/jenkins/values.yaml stable/jenkins

jenkins-upgrade:
	helm upgrade j-v1 -f k8s/jenkins/values.yaml stable/jenkins

jenkins-local:
	kubectl --namespace ci port-forward svc/j-v1-jenkins  8080:8080

backend-local:
	@echo "To test  backend in: http://localhost:8080/"
	kubectl --namespace production port-forward svc/app-backend  8080:8080

frontend-local:
	@echo "To test  frontend in: http://localhost:8082/"
	kubectl --namespace production port-forward svc/app-frontend  8082:80

# run-backend:
# 	docker network create sample-nt
#     $(shell docker run --rm -p 8080:8080 --name backend --network sample-nt krol/app-go:dev)

# run-frontend:
# 	$(shell docker run --rm -p 8085:8085 --network sample-nt krol/app-go:dev ./app -frontend=true -backend-service=http://backend:8080 -port=8085)