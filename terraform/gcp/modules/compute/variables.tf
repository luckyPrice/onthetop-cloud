# compute module variables.tf

variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "image" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "internal_ip" {
  type        = string
  description = "Optional static internal IP to assign"
}

variable "ssh_keys" {
  type        = string
  description = "SSH keys for metadata injection"
}

variable "external_ip" {
  type        = string
  default     = null
  description = "Optional static external IP address"
}

variable "tags" {
  description = "Network tags to apply to the instance"
  type        = list(string)
  default     = []
}
