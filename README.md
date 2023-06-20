# Demo s3 cdn website

GOHugo static website to demonstrate setting up a s3 website with cloudfront as cdn and ACM certificate

The deployment behind cloudfront can be found at https://demo.di.works/

I will take it down soon(ish).

## Usage

Edit the `config.yaml` file to your hearts content (remember to update the `bucket name` and `cloudFrontDistributionID`) (see note 7) and then:

```
make theme                          # to get the hugo-fresh theme
make build                          # build the base image (not strictly necessary for the static site but evidence for containerization)
make tf-init tf-plan tf-apply       # setup terraform uses your "default" profile but can be overrident in `terraform/overlays/demo/providers.tf`
make generate                       # generate html for local review
make run                            # run the setup locally open http://localhost:1313
make deploy                         # deploy to the configured s3 bucket and flush cdn
```

## Notes

1. made use of cloudposse s3 cloudfront modules. Abstracted via the overlay which allows us to change to another provider if necessary
2. acm best uses us-east-1 thus need to provide multiple providers vai tf aliases
3. disabled logging (normally would enable it or make use of a system like umami for cookieless tracking)
4. `Makefile` - I use make or "`just`" (https://github.com/casey/just) to integrate with build tooling. This pattern allows developers to execute the same sequences locally as the pipeline would and allows for simpler debugging in any POSIX complient environment.
5. you can then setup a `gitlab-ci.yml` or `Jenkinsfile` or whatever `ci` tool you use to build, and can then trigger whatever `cd` tooling is in use (argocd,harness,spinnacker,etc)
6. as noted in the `providers.tf` state must ALWAYS be stored in a remote s3 bucket thats encrypted at rest, however for the purposes of this demo an exception is made.
7. I would normally also automate the CDN_ID and BUCKET_NAME in the `config.yaml` by using `jq` to parse the terraform outputs and `sed` to replace values in `config.yaml:deployment.targets[0]`

## Rationale and Other options

As there was no specific deployment target provided I selected hugo (JAMStack and simple s3 cdn), I try to stick with cost effective and performant options relative to the business case.

Ideally I prefer containerized applicatons, however there was no need for a full blown container as the specification was simple html.

I have however provided a `Dockerfile` and `Dockerfile.mailer` which would be integrated into the build and deploy makefile targets which would be pushed to a reigstry
and could be deployed to another deployment target like `k8s` or `ecs` or even `lambda`

`mailer.py` is a very simple mail script which could be used to take a contact form submitted (although would also require csrf in place)
`Caddyfile` caddy is a simple server that also has the offering of tls however I use it for k8s/containerized deployments as its high performance and super simple

In a best case scenario, I would deploy the application to a kubernetes cluster that has external-dns,cert-manager and nginx-ingress to handle ingress and tls (this can be seen in `k8s/*` folder.
Additionally I tend to use `skaffold` which is the go-to kubernetes SDLC tools for both ci as well as dev to ephemeral environments.
