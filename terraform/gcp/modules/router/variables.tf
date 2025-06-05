# router module variables.tf

variable "name" {
  description = "Name of the Cloud Router"
  type        = string
}

variable "region" {
  description = "Region of the Cloud Router"
  type        = string
}

variable "network" {
  description = "VPC network ID (self_link) the router is associated with"
  type        = string
}

