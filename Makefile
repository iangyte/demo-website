.SHELL := /usr/bin/bash
.EXPORT_ALL_VARIABLES:

export TF_IN_AUTOMATION = 1
export README_INCLUDES ?= $(file://$(shell pwd)/?type=text/plain)

WIZ_POLICES="Dan - Demo Vulnerabilities Policy,Dan - Sensitive Data Default"

help:
	@grep -E '^[a-zA-Z_-_\/]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build website
	@docker buildx build --platform linux/amd64 . -t gytedocker/site:latest
	#@docker image inspect gytedocker/site:latest

deploy: ## Deploy website
	@helm upgrade secsite-hugo ./helm/igyte-secsite \
		--namespace=igyte \
		--create-namespace \
		--wait \
		--install \
		--values helm/igyte-secsite/values.yaml \
		--set image.repository=gytedocker/site \
		--set image.tag=latest
scan: ## Scan image
	wizcli docker scan  --sensitive-data  --secrets --policy $(WIZ_POLICES) --image gytedocker/site:latest 

scan/dockerfile: ## Scan dockerfile
	wizcli docker scan  --sensitive-data  --secrets --image gytedocker/site:latest --dockerfile Dockerfile

scan/dir: ## Scan image
	wizcli dir scan  --sensitive-data  --secrets --policy $(WIZ_POLICES) --path .


delete: ## Deploy website
	@helm uninstall secsite-hugo

run: ## Run site in docker
	echo "Goto http://localhost:8080/"
	docker run -p 8080:80 gytedocker/site

push: ## Piush to docker repo
	@docker tag gytedocker/site:latest gytedocker/site:latest
	@docker push gytedocker/site:latest