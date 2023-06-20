.PHONY: all build push run deploy

DOMAIN      := demo.di.works
AWS_PROFILE := default
NAME     	:= rosscdh/personal-di-works
TAG      	:= $$(git log -1 --pretty=%h)
VERSION  	:= ${NAME}:${TAG}
LATEST   	:= ${NAME}:latest

export

all: build tf-init

build:
	docker build -t ${LATEST} -t ${VERSION} .
	trivy image --quiet --severity CRITICAL ${VERSION}

validate-images: build
	trivy image --quiet --severity CRITICAL ${VERSION}
	trivy image --quiet --severity CRITICAL ${LATEST}
	trivy image --quiet --severity CRITICAL jakejarvis/hugo-extended

push:
	docker push ${LATEST}
	docker push ${VERSION}

theme:
	git clone https://github.com/StefMa/hugo-fresh ./themes/hugo-fresh
	git clone https://github.com/jgthms/bulma ./themes/bulma

tf-init:
	pushd terraform/overlays/demo;terraform init;popd
tf-validate:
	pushd terraform/overlays/demo;terraform validate;popd
tf-plan: tf-validate
	pushd terraform/overlays/demo;terraform plan;popd
tf-apply: tf-validate
	pushd terraform/overlays/demo;terraform apply;popd

run:
	docker run --rm -it -v ${PWD}:/src -p 1313:1313 --entrypoint hugo jakejarvis/hugo-extended server --bind 0.0.0.0 --config /src/config.yaml

run-prod:
	docker run --rm -it -v ${PWD}/Caddyfile:/etc/caddy/Caddyfile -e CADDY_HOST='http://0.0.0.0' -p 8080:80 ${VERSION}

generate:
	docker run --rm -it -v ${PWD}:/src --entrypoint hugo jakejarvis/hugo-extended --config /src/config.yaml

deploy: generate
	docker run --rm -it -e AWS_PROFILE=${AWS_PROFILE} -v ${HOME}/.aws:/root/.aws -v ${PWD}:/src --entrypoint hugo jakejarvis/hugo-extended deploy --config /src/config.yaml