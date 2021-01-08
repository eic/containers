# import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
# exports variables in config.env as environment variables
export $(shell sed 's/=.*//' $(cnf))


# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`

SHELL = bash

## Get our version tag and stable version tag
VERSION=$(shell head -n1 ../../VERSION)
STABLE=$(shell echo ${$(head -n1 ../../VERSION)%.*}-stable)

# help will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# ==========================================================================
#
build: ## build the image
	docker build -t $(APP_NAME):$(VERSION) .
build-unstable: ## build the image
	docker build -t $(APP_NAME):$(VERSION)-unstable .

build-nc: ## Build the container without caching (from scratch)
	docker build --no-cache -t $(APP_NAME):$(VERSION) .
build-unstable-nc: ## Build the container without caching (from scratch)
	docker build --no-cache -t $(APP_NAME):$(VERSION)-unstable .

# ==========================================================================
#
login: ## Auto login to AWS-ECR unsing aws-cli
	docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}/${CI_PROJECT_PATH}
	echo "Login COMPLETE"

stable: build-nc
stable-cached: build
unstable: build-unstable-nc 
unstable-cached: build-unstable 

publish: login publish-latest publish-version #publish-version ## Publish the `{version}` ans `latest` tagged containers to ECR
	@echo "Publishing done"


publish-stable: login 
	@echo 'publish $(STABLE) to $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME)'
	docker tag $(APP_NAME):$(VERSION) $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):$(STABLE)
	docker push $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):$(STABLE)

publish-latest: login 
	@echo 'publish latest to $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME)'
	docker tag $(APP_NAME):$(VERSION) $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):latest
	docker push $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):latest

publish-version: login 
	@echo 'publish $(STABLE) to $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME)'
	docker tag $(APP_NAME):$(VERSION) $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):$(VERSION)
	docker push $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):$(VERSION)

publish-unstable: login 
	@echo 'publish unstable to $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME)'
	docker tag $(APP_NAME):$(VERSION)-unstable $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):unstable
	docker push $(REG_NAME)/$(GL_REG_GROUP)/$(APP_NAME):unstable

version: ## Output the current version
	@echo $(VERSION)

# ==========================================================================
#
info: ## Output the current version
	@echo 'VERSION      = $(VERSION)     '
	@echo 'STABLE       = $(STABLE)      '
	@echo 'REG_NAME     = $(REG_NAME)    '
	@echo 'APP_NAME     = $(APP_NAME)    '
	@echo 'GL_GROUP     = $(GL_GROUP)    '
	@echo 'GL_REG_GROUP = $(GL_REG_GROUP)'
	@echo 'GL_REG_NAME  = $(GL_REG_NAME) '
