# create acm and explicitly set it to us-east-1 provider
module "acm_request_certificate" {
  source                            = "cloudposse/acm-request-certificate/aws"
  version                           = "0.17.0"
  domain_name                       = var.domain
  subject_alternative_names         = var.sans
  process_domain_validation_options = true
  ttl                               = "300"

  providers = {
    aws = aws.us-east-1
  }
}

module "cdn" {
  source = "cloudposse/cloudfront-s3-cdn/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version                            = "0.90.0"
  namespace                          = "eg"
  stage                              = "dev"
  name                               = var.name
  aliases                            = [var.domain]
  dns_alias_enabled                  = true
  block_origin_public_access_enabled = true
  cloudfront_access_logging_enabled  = false
  parent_zone_id                     = var.parent_zone_id

  acm_certificate_arn = module.acm_request_certificate.arn

  depends_on = [module.acm_request_certificate]
}