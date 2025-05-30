# firewall module variables.tf

variable "name" {
  type = string
}

variable "port" {
  type = list(string)
}

variable "source_ranges" {
  type = list(string)
}

variable "target_tag" {
  type = string
}

variable "network" {
  type = string
}
