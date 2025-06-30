# AWS 리전 (AWS Region)
variable "aws_region" {
  description = "AWS Region to deploy resources" # 리소스를 배포할 AWS 리전
  type        = string
  default     = "ap-northeast-2" # 서울 리전
}

# 가용 영역 (Availability Zones)
variable "azs" {
  description = "List of Availability Zones to use for VPC subnets" # VPC 서브넷에 사용할 가용 영역 목록
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

# Prod VPC CIDR 블록 (Prod VPC CIDR Block)
variable "prod_vpc_cidr_block" {
  description = "CIDR block for the Prod VPC" # Prod VPC의 CIDR 블록
  type        = string
  default     = "10.20.0.0/16"
}

# Shared VPC ID (Shared VPC ID)
# 피어링을 위해 기존 Shared VPC의 ID를 입력해야 합니다.
variable "shared_vpc_id" {
  description = "The ID of the EXISTING Shared VPC for peering" # 피어링을 위한 기존 Shared VPC의 ID
  type        = string
  default     = "vpc-06ab5451f12784644" #kubeadm-shared VPC ID (kubeadm-shared VPC ID confirmed from image)
}

# Shared VPC CIDR 블록 (Shared VPC CIDR Block)
# 라우팅을 위해 Shared 환경의 CIDR 블록을 입력받아야 합니다.
variable "shared_vpc_cidr_block" {
  description = "The CIDR block of the Shared VPC for routing" # 라우팅을 위한 Shared VPC의 CIDR 블d
  type        = string
  default     = "10.0.0.0/16"
}

# EKS 클러스터 이름 (EKS Cluster Name)
variable "eks_cluster_name" {
  description = "Name of the EKS cluster" # EKS 클러스터 이름
  type        = string
  default     = "my-prod-eks-cluster" # 클러스터 이름 변경 (Changed cluster name)
}

# EKS 클러스터 Kubernetes 버전 (EKS Cluster Kubernetes Version)
variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster" # EKS 클러스터의 Kubernetes 버전
  type        = string
  default     = "1.28"
}

# EKS 노드 인스턴스 타입 (EKS Node Instance Type)
variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes" # EKS 워커 노드의 EC2 인스턴스 타입
  type        = string
  default     = "t3.medium"
}

# 노드 그룹 최소 수 (Node Group Minimum Size)
variable "eks_node_min_size" {
  description = "Minimum number of nodes in the EKS node group" # EKS 노드 그룹의 최소 노드 수
  type        = number
  default     = 1
}

# 노드 그룹 최대 수 (Node Group Maximum Size)
variable "eks_node_max_size" {
  description = "Maximum number of nodes in the EKS node group" # EKS 노드 그룹의 최대 노드 수
  type        = number
  default     = 2
}

# 노드 그룹 희망 수 (Node Group Desired Size)
variable "eks_node_desired_size" {
  description = "Desired number of nodes in the EKS node group" # EKS 노드 그룹의 희망 노드 수
  type        = number
  default     = 1
}
