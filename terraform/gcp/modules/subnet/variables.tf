# subnet module variables.tf

variable "name" {
  description = "서브넷 이름"
  type        = string
}

variable "region" {
  description = "서브넷이 속할 GCP 리전"
  type        = string
}

variable "cidr" {
  description = "CIDR 블록 (예: 10.11.0.0/16)"
  type        = string
}

variable "network" {
  description = "연결할 VPC 네트워크 ID"
  type        = string
}
