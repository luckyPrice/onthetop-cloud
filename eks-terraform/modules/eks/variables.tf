# EKS 클러스터 이름 (EKS Cluster Name)
variable "cluster_name" {
  description = "Name of the EKS cluster" # EKS 클러스터 이름
  type        = string
}

# EKS 클러스터 Kubernetes 버전 (EKS Cluster Kubernetes Version)
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster" # EKS 클러스터의 Kubernetes 버전
  type        = string
}

# VPC ID (VPC ID)
variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed" # EKS 클러스터가 배포될 VPC의 ID
  type        = string
}

# 서브넷 ID 목록 (Subnet IDs)
variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster and node group" # EKS 클러스터 및 노드 그룹용 서브넷 ID 목록
  type        = list(string)
}

# EKS 클러스터 IAM 역할 ARN (EKS Cluster IAM Role ARN)
variable "eks_cluster_iam_role_arn" {
  description = "ARN of the IAM role for the EKS cluster" # EKS 클러스터용 IAM 역할 ARN
  type        = string
}

# EKS 노드 IAM 역할 ARN (EKS Node IAM Role ARN)
variable "eks_node_iam_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes" # EKS 워커 노드용 IAM 역할 ARN
  type        = string
}

# EBS CSI IAM 역할 ARN (EBS CSI IAM Role ARN)
variable "ebs_csi_iam_role_arn" {
  description = "ARN of the IAM role for the EBS CSI driver" # EBS CSI 드라이버용 IAM 역할 ARN
  type        = string
}

# 노드 그룹 인스턴스 타입 (Node Group Instance Type)
variable "instance_type" {
  description = "EC2 instance type for EKS worker nodes" # EKS 워커 노드의 EC2 인스턴스 타입
  type        = string
}

# 노드 그룹 용량 타입 (Node Group Capacity Type)
variable "capacity_type" {
  description = "Capacity type for the EKS node group (ON_DEMAND or SPOT)" # EKS 노드 그룹의 용량 타입 (ON_DEMAND 또는 SPOT)
  type        = string
}

# 노드 그룹 최소 크기 (Node Group Minimum Size)
variable "min_size" {
  description = "Minimum number of nodes in the EKS node group" # EKS 노드 그룹의 최소 노드 수
  type        = number
}

# 노드 그룹 최대 크기 (Node Group Maximum Size)
variable "max_size" {
  description = "Maximum number of nodes in the EKS node group" # EKS 노드 그룹의 최대 노드 수
  type        = number
  default     = 3
}

# 노드 그룹 희망 크기 (Node Group Desired Size)
variable "desired_size" {
  description = "Desired number of nodes in the EKS node group" # EKS 노드 그룹의 희망 노드 수
  type        = number
}
