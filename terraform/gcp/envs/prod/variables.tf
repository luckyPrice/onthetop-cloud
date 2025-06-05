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

variable "private_subnet_cidr" {
  type        = string
}
variable "db_primary_subnet_cidr" {
  type        = string
}
variable "db_secondary_subnet_cidr" {
  type        = string
}

variable "backend_machine_type" {
  type        = string
  default     = "e2-small"
}
variable "db_machine_type" {
  type        = string
  default     = "e2-small"
}

variable "backend_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts"
}
variable "db_image" {
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2404-lts"
}

variable "ssh_keys" {
  type        = string
  description = "SSH public keys in metadata format"
}
