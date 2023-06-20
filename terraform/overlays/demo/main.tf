module "demo" {
  source = "../../personal-di-works/v1"

  name           = "demo"
  parent_zone_id = "Z06530201CX2R1FPP2IKK"
  domain         = "demo.di.works"
  sans           = ["personal.di.works"]
  providers = {
    aws           = aws.ap-southeast-2
    aws.us-east-1 = aws.us-east-1
  }

}