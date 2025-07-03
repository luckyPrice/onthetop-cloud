# EKS 클러스터 이름 (EKS Cluster Name)
output "eks_cluster_name" {
  description = "The name of the EKS cluster" # EKS 클러스터의 이름
  value       = module.eks_cluster.cluster_name
}

# EKS 클러스터 엔드포인트 (EKS Cluster Endpoint)
output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster" # EKS 클러스터의 엔드포인트
  value       = module.eks_cluster.cluster_endpoint
}

# EKS 클러스터 OIDC 제공자 ARN (EKS Cluster OIDC Provider ARN)
output "eks_cluster_oidc_provider_arn" {
  description = "The ARN of the EKS cluster's OIDC provider" # EKS 클러스터 OIDC 제공자의 ARN
  value       = module.eks_cluster.oidc_provider_arn
}

# Prod VPC ID (Prod VPC ID)
output "prod_vpc_id" {
  description = "The ID of the Prod VPC" # Prod VPC의 ID
  value       = module.prod_vpc.vpc_id
}

# VPC 피어링 연결 ID (VPC Peering Connection ID)
# Prod에서 Shared VPC로의 피어링 연결 ID를 출력합니다.
output "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection from Prod to Shared VPC" # Prod에서 Shared VPC로의 VPC 피어링 연결 ID
  value       = aws_vpc_peering_connection.prod_to_shared.id
}

# Kubeconfig CLI 명령어 (Kubeconfig CLI Command)
output "configure_kubectl" {
  description = "Command to configure kubectl for the EKS cluster" # EKS 클러스터용 kubectl을 구성하는 명령어
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
}

# ==============================================================================
# Argo CD 관련 출력
# ==============================================================================



# Argo CD 초기 관리자 비밀번호 (Argo CD Initial Admin Password)
# 이 비밀번호로 Argo CD UI에 'admin' 사용자로 로그인합니다. (Login to Argo CD UI with 'admin' user using this password.)
output "argocd_initial_admin_password" {
  description = "The initial admin password for Argo CD" # Argo CD의 초기 관리자 비밀번호
  value     = data.kubernetes_secret.argocd_initial_admin_secret.data["password"]
  sensitive = true # 민감한 정보로 표시 (Mark as sensitive)
}
# Argo CD 서버 로드 밸런서 URL (Argo CD Server Load Balancer URL)
output "argocd_server_url" {
  description = "The external URL for the Argo CD server (LoadBalancer)" # Argo CD 서버의 외부 URL (로드 밸런서)
  # LoadBalancer Ingress 호스트네임이 존재할 경우에만 값을 출력합니다.
  value       = try(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname, "")
}


# Argo CD CLI/UI 접근 명령어 (Port Forwarding) (Argo CD CLI/UI Access Command - Port Forwarding)
output "argocd_port_forward_command" {
  description = "Command to access Argo CD UI/CLI via kubectl port-forward" # kubectl port-forward를 통해 Argo CD UI/CLI에 접근하는 명령어
  value       = "kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

# Argo CD CLI 로그인 명령어 (Port Forwarding 후) (Argo CD CLI Login Command - After Port Forwarding)
output "argocd_cli_login_command_after_pf" {
  description = "Command to login to Argo CD CLI (after running port-forward command)" # kubectl port-forward 실행 후 Argo CD CLI에 로그인하는 명령어
  value       = "argocd login localhost:8080 --insecure" # Port-forward된 로컬 주소 사용 (Use port-forwarded local address)
}