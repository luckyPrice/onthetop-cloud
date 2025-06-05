# mig module variables.tf

variable "name" { type = string }
variable "project_id" { type = string }
variable "region" { type = string }

variable "instance_template" { type = string }
variable "instance_base_name" {
  type    = string
  default = null
}

variable "target_size" { type = number }

variable "named_port" {
  type = string
  default = "http"
}

variable "port" {
  type = number
  default = 80
}

variable "health_check" {
  type    = string
  default = null
}

variable "auto_healing_initial_delay" {
  type    = number
  default = 60
}

variable "update_policy" {
  description = "MIG update policy settings"
  type = object({
    type                   = string
    minimal_action         = string
    replacement_method     = string
    max_surge_fixed        = number
    max_unavailable_fixed  = number
  })
  default = {
    type                   = "PROACTIVE"
    minimal_action         = "REPLACE"
    replacement_method     = "RECREATE"
    max_surge_fixed        = 1
    max_unavailable_fixed  = 0
  }
}
