# cloud_nat module variables.tf

variable "name" {
  description = "Name of the Cloud NAT resource"
  type        = string
}

variable "region" {
  description = "Region where NAT will be deployed"
  type        = string
}

variable "router" {
  description = "Name of the Cloud Router (not self_link)"
  type        = string
}
