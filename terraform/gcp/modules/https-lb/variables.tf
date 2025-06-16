# lb module variables.tf

variable "name" {
  type        = string
  description = "공통 prefix로 사용될 Load Balancer 이름 (예: onthetop-prod)"
}

variable "instance_group" {
  type        = string
  description = "연결할 MIG의 instance group self_link"
}

variable "health_check" {
  type        = string
  description = "연결할 health check의 self_link"
}

variable "port_name" {
  type        = string
  default     = "http"
  description = "백엔드 서비스의 named port 이름"
}

variable "certificate_map" {
  type        = string
  description = "Certificate Manager용 certificate map resource ID"
  default     = null
}
