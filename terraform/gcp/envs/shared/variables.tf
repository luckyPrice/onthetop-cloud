variable "project_id" {
  type        = string
  description = "GCP project ID"
}
variable "region" {
  type        = string
  default     = "asia-northeast3"
}
variable "zone" {
  type        = string
  default = "asia-northeast3-a"
}
variable "env" {
  type        = string
  description = "Environment (e.g. dev, prod)"
}

variable "public_subnet_cidr" {
  type = string
}

variable "shared_machine_type" {
  type = string
}

variable "shared_image" {
  type = string
}

variable "ssh_keys" {
  type = string
}
