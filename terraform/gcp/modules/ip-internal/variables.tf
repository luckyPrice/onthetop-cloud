# ip-internal module variables.tf

variable "name" {
  description = "The name of the internal IP address"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork self-link to bind this IP"
  type        = string
}
