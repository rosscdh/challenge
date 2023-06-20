.PHONY: all setup build push run deploy

DOMAIN      := demo.di.works
AWS_PROFILE := default
NAME     	:= rosscdh/personal-di-works
TAG      	:= $$(git log -1 --pretty=%h)
VERSION  	:= ${NAME}:${TAG}
LATEST   	:= ${NAME}:latest

export

all: build tf-init

setup:
	brew install trivy jq skaffold terraform conftest

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
	git clone --depth 1 https://github.com/StefMa/hugo-fresh ./themes/hugo-fresh | true
	git clone --depth 1 https://github.com/jgthms/bulma ./themes/github.com/jgthms/bulma | true

tf-init:
	sed -i.bak "s/profile.*/profile = \"${AWS_PROFILE}\"/g" terraform/overlays/demo/providers.tf
	pushd terraform/overlays/demo;terraform init;popd
tf-validate:
	pushd terraform/overlays/demo;terraform validate;popd
tf-plan: tf-validate
	pushd terraform/overlays/demo;terraform plan;popd
tf-apply: tf-validate
	pushd terraform/overlays/demo;terraform apply;popd

# update-config:
# 	CF_ID=`cat terraform/overlays/demo/terraform.tfstate | jq -rc '.outputs.cloudfront_id.value'` yq e ".deployment.targets[0].cloudFrontDistributionID = strenv(CF_ID)" config.yaml
# 	S3_BUCKET=`cat terraform/overlays/demo/terraform.tfstate | jq -rc '.outputs.s3_bucket.value'` yq e ".deployment.targets[0].url = strenv(S3_BUCKET)" config.yaml

run:
	docker run --rm -it -v ${PWD}:/src -p 1313:1313 --entrypoint hugo jakejarvis/hugo-extended server --bind 0.0.0.0 --config /src/config.yaml

run-prod:
	docker run --rm -it -v ${PWD}/Caddyfile:/etc/caddy/Caddyfile -e CADDY_HOST='http://0.0.0.0' -p 8080:80 ${VERSION}

generate:
	docker run --rm -it -v ${PWD}:/src --entrypoint hugo jakejarvis/hugo-extended --config /src/config.yaml

deploy: generate
	docker run --rm -it -e AWS_PROFILE=${AWS_PROFILE} -v ${HOME}/.aws:/root/.aws -v ${PWD}:/src --entrypoint hugo jakejarvis/hugo-extended deploy --config /src/config.yaml