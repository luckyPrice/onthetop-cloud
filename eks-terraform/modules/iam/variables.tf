# EKS 클러스터 이름 (EKS Cluster Name)
variable "cluster_name" {
  description = "Name of the EKS cluster for IAM role naming" # IAM 역할 명명을 위한 EKS 클러스터 이름
  type        = string
}

# OIDC 제공자 ARN (OIDC Provider ARN)
variable "oidc_provider_arn" {
  description = "ARN of the EKS cluster's OIDC provider" # EKS 클러스터 OIDC 제공자의 ARN
  type        = string
}

# OIDC 제공자 URL (OIDC Provider URL)
variable "oidc_provider_url" {
  description = "URL of the EKS cluster's OIDC provider" # EKS 클러스터 OIDC 제공자의 URL
  type        = string
}
