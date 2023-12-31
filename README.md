# Demo s3 cdn website

GOHugo static website to demonstrate setting up a s3 website with cloudfront as cdn and ACM certificate

The deployment behind cloudfront can be found at https://demo.di.works/

I will take it down soon(ish).

`@NB` please remember if you clone this to /tmp/ docker will probably not mount files due to permissions.


## Usage

1. Change the `name` and zone properties to yor new site in `terraform/overlays/demo/main.tf`
2. Remember to update the `bucket name` and `cloudFrontDistributionID` in `config.yaml` (see note 7)
2. Edit the `config.yaml` add sections, change content file to your hearts content.

## Available helper commands

```
make setup                          # install (using brew sorry) the required cli tooling
make theme                          # to get the hugo-fresh theme
make build                          # build the base image (not strictly necessary for the static site but evidence for containerization)
make tf-init tf-plan tf-apply       # setup terraform - tf-init will set the alias profile (in `terraform/overlays/demo/providers.tf`) to be the AWS_PROFILE defined in the Makefile
make show-config                    # once the terraform has been applied you can get the s3_bucket name and cdn_id with this command
make generate                       # generate html for local review
make run                            # run the setup locally open http://localhost:1313
make deploy                         # deploy to the configured s3 bucket and flush cdn - will use AWS_PROFILE and mounted aws creds
make validate-images                # validate all the images in use
make run-prod                       # run the production image with caddy open http://localhost:8080
```

## Notes

1. made use of cloudposse s3 cloudfront modules. Abstracted via the overlay which allows us to change to another provider if necessary
2. acm best uses us-east-1 thus need to provide multiple providers via tf aliases
3. disabled logging (normally would enable it or make use of a system like umami for cookieless tracking)
4. `Makefile` - I use make or "`just`" (https://github.com/casey/just) to integrate with build tooling. This pattern allows developers to execute the same sequences locally as the pipeline would and allows for simpler debugging in any POSIX complient environment.
5. you can then setup a `gitlab-ci.yml` or `Jenkinsfile` or whatever `ci` tool you use to build, and can then trigger whatever `cd` tooling is in use (argocd,harness,spinnacker,etc)
6. as noted in the `providers.tf` terraform state must `ALWAYS` be stored in a remote s3 bucket thats encrypted at rest, however for the purposes of this demo an exception is made and the terraform.state* file is `.gitignored`
7. I would normally also automate the CDN_ID and BUCKET_NAME in the `config.yaml` by using `jq` to parse the terraform outputs and `sed` to replace values in `config.yaml:deployment.targets[0]` but for demo purposes simply have a `show-config` make target
8. I have added trivy and terraform validate as basic sanity checks, but would also add a degree of governance using `conftest` (OPA https://www.conftest.dev/) or similar based on policy which would be pulled from a centralised managed repo.
9. of course a `terraform.lock` would be used in pipelines
10. trivy evaluates only CRITICAL for this demo, as usually thats the high-water mark where action needs to take place and tickets generated

## Rationale and Other options

As there was no specific deployment target required in the brief, I selected hugo (JAMStack and simple s3 cdn). I generally try to stick with cost effective and performant options relative to the business case.

Ideally I prefer containerized applicatons, however there was no need for a full blown container as the specification was simple html.

I have however provided a `Dockerfile` and `Dockerfile.mailer` which would be integrated into the build and deploy makefile targets which would be pushed to a reigstry
and could be deployed to another deployment target like `k8s` or `ecs` or even `lambda`

`mailer.py` is a very simple mail script which could be used to take a contact form submitted (although would also require csrf in place)
`Caddyfile` caddy is a simple server that also has the offering of tls however I use it for k8s/containerized deployments as its high performance and super simple

In a best case scenario, I would deploy the application to a kubernetes cluster that has external-dns,cert-manager and nginx-ingress to handle ingress and tls (this can be seen in `k8s/*` folder.
Additionally I tend to use `skaffold` which is the go-to kubernetes SDLC tools for both ci as well as dev to ephemeral environments.
