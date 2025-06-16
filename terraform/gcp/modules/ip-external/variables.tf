# ip-external module variables.tf

variable "name" {
  description = "The name of the external IP address"
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
