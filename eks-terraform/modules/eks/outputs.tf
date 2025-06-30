# EKS 클러스터 이름 (EKS Cluster Name)
output "cluster_name" {
  description = "The name of the EKS cluster" # EKS 클러스터의 이름
  value       = aws_eks_cluster.main.name
}

# EKS 클러스터 엔드포인트 (EKS Cluster Endpoint)
output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster" # EKS 클러스터의 엔드포인트
  value       = aws_eks_cluster.main.endpoint
}

# EKS 클러스터 인증 기관 데이터 (EKS Cluster Certificate Authority Data)
output "cluster_certificate_authority_data" {
  description = "The base64 encoded certificate data required to communicate with your cluster" # 클러스터와 통신하는 데 필요한 base64 인코딩된 인증서 데이터
  value       = aws_eks_cluster.main.certificate_authority.0.data
}

# OIDC 제공자 ARN (OIDC Provider ARN)
output "oidc_provider_arn" {
  description = "The ARN of the EKS cluster's OIDC provider" # EKS 클러스터 OIDC 제공자의 ARN
  value       = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

# OIDC 제공자 URL (OIDC Provider URL)
output "oidc_provider_url" {
  description = "The URL of the EKS cluster's OIDC provider" # EKS 클러스터 OIDC 제공자의 URL
  value       = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

# Kubeconfig 파일 경로 (Kubeconfig File Path)
output "kubeconfig_filepath" {
  description = "The local path to the generated kubeconfig file" # 생성된 kubeconfig 파일의 로컬 경로
  value       = local_file.kubeconfig.filename
}

# Kubeconfig 내용 (Kubeconfig Content)
output "kubeconfig" {
  description = "The content of the generated kubeconfig file" # 생성된 kubeconfig 파일의 내용
  value       = local_file.kubeconfig.content
  sensitive   = true # 민감한 정보로 표시 (Mark as sensitive)
}

# EKS 클러스터 기본 보안 그룹 ID (EKS Cluster Default Security Group ID)
# EKS 클러스터가 자동으로 생성하는 보안 그룹입니다. (Security group automatically created by EKS cluster.)
output "eks_cluster_security_group_id" {
  description = "The ID of the EKS cluster default security group" # EKS 클러스터 기본 보안 그룹의 ID
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

# EKS 노드 그룹 보안 그룹 ID (EKS Node Group Security Group ID)
# 워커 노드에 연결된 보안 그룹입니다. (Security group attached to worker nodes.)
output "eks_node_security_group_id" {
  description = "The ID of the EKS node group security group" # EKS 노드 그룹 보안 그룹의 ID
  value = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}