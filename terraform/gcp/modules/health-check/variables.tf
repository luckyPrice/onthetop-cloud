# health-check module variables.tf

variable "name" {
  type = string
}

variable "project_id" {
  type = string
}

variable "protocol" {
  type    = string
  default = "TCP"
  validation {
    condition     = contains(["TCP", "HTTP", "HTTPS"], var.protocol)
    error_message = "protocol must be one of: TCP, HTTP, HTTPS"
  }
}

variable "port" {
  type = number
}

variable "request_path" {
  type    = string
  default = "/"
}

variable "check_interval_sec" {
  type    = number
  default = 5
}

variable "timeout_sec" {
  type    = number
  default = 5
}

variable "healthy_threshold" {
  type    = number
  default = 2
}

variable "unhealthy_threshold" {
  type    = number
  default = 2
}
