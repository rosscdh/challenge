variable "name" {
  type        = string
  description = "the name for this project"
}

variable "domain" {
  type        = string
  description = "the domain for this website"
}

variable "parent_zone_id" {
  type        = string
  description = "the hosted zone id"
}

variable "sans" {
  type        = list(string)
  description = "a list of subject alternative names for the certificate"
}