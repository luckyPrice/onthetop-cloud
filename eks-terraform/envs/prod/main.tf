# AWS Provider 설정 (AWS Provider Configuration)
provider "aws" {
  region = var.aws_region # variables.tf에 정의된 AWS 리전 사용
}

# Kubernetes 클러스터 인증을 위한 데이터 소스 (Data source for Kubernetes cluster authentication)
# EKS 클러스터의 인증 토큰을 가져오는 데 사용됩니다. (Used to get the authentication token for the EKS cluster.)
# 이 데이터 소스를 provider 블록에서 사용하기 전에 선언합니다. (Declare this data source before it's used in provider blocks.)
data "aws_eks_cluster_auth" "main" {
  name = module.eks_cluster.cluster_name
}

# Kubernetes Provider 설정 (Kubernetes Provider Configuration)
# Terraform이 EKS 클러스터와 통신하기 위해 필요합니다.
# EKS 클러스터 모듈의 출력값을 사용합니다.
provider "kubernetes" {
  # host 설정을 EKS 클러스터 엔드포인트로 명시적으로 지정합니다.
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.main.token
  # Provider 블록 내에서는 depends_on을 사용하지 않습니다. (Do not use depends_on within provider block.)
}

# Helm Provider 설정 (Helm Provider Configuration)
# Terraform이 Helm 차트를 사용하여 Kubernetes에 애플리케이션을 배포하기 위해 필요합니다.
# Kubernetes Provider에 의존합니다.
provider "helm" {
  # Kubernetes 설정은 상위 provider "kubernetes"에서 자동으로 상속됩니다.
  # 여기서는 중첩된 kubernetes {} 블록을 제거합니다.
  # The Kubernetes configuration is automatically inherited from the top-level provider "kubernetes".
  # Removing the nested kubernetes {} block here.

  # Provider 블록 내에서는 depends_on을 사용하지 않습니다. (Do not use depends_on within provider block.)
}

# 1. Prod VPC 모듈 호출 (Calling the Prod VPC Module)
# EKS 클러스터가 배포될 새로운 Prod VPC를 생성합니다.
module "prod_vpc" {
  source = "../../modules/vpc" # vpc 모듈 경로 (상대 경로 조정)
  name   = "prod"
  cidr_block = var.prod_vpc_cidr_block # 10.20.0.0/16 (새로운 VPC)

  azs        = var.azs # 가용 영역 목록
  # 각 서브넷의 CIDR 블록을 정의합니다. Prod VPC의 새로운 대역 (10.20.0.0/16)에 맞게 조정합니다.
  public_subnet_cidrs  = ["10.20.0.0/20", "10.20.16.0/20", "10.20.32.0/20"]
  private_subnet_cidrs = ["10.20.64.0/20", "10.20.80.0/20", "10.20.96.0/20"]
  database_subnet_cidrs = ["10.20.128.0/20", "10.20.144.0/20", "10.20.160.0/20"]

  # EKS 워커 노드가 인터넷에 접근할 수 있도록 NAT Gateway를 활성화합니다.
  enable_nat_gateway = true
}

# 2. IAM 모듈 호출 (Calling the IAM Module)
# EKS 클러스터, 노드 그룹 및 EBS CSI 드라이버에 필요한 IAM 역할을 생성합니다.
module "iam" {
  source = "../../modules/iam" # iam 모듈 경로 (상대 경로 조정)
  cluster_name = var.eks_cluster_name # EKS 클러스터 이름
  # EKS 클러스터의 OIDC Provider URL을 사용하여 EBS CSI 드라이버 역할을 구성합니다.
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  oidc_provider_url = module.eks_cluster.oidc_provider_url
}

# 3. EKS 모듈 호출 (Calling the EKS Module)
# Prod VPC 내에 EKS 클러스터 및 노드 그룹을 생성합니다.
module "eks_cluster" {
  source = "../../modules/eks" # eks 모듈 경로 (상대 경로 조정)
  cluster_name = var.eks_cluster_name # EKS 클러스터 이름
  cluster_version = var.eks_cluster_version # Kubernetes 버전
  vpc_id = module.prod_vpc.vpc_id # EKS를 새로 생성된 Prod VPC에 배포
  subnet_ids = module.prod_vpc.private_subnet_ids # Prod VPC의 private 서브넷 사용
  # EKS 클러스터 및 노드 그룹에 필요한 IAM 역할 ARN을 전달합니다.
  eks_cluster_iam_role_arn = module.iam.eks_cluster_iam_role_arn
  eks_node_iam_role_arn    = module.iam.eks_node_iam_role_arn
  ebs_csi_iam_role_arn     = module.iam.eks_ebs_csi_iam_role_arn

  # 노드 그룹 구성 (Node Group Configuration)
  instance_type = var.eks_node_instance_type # t3.medium
  capacity_type = "SPOT" # Spot 인스턴스 사용
  min_size      = var.eks_node_min_size # 최소 노드 수
  max_size      = var.eks_node_max_size # 최대 노드 수
  desired_size  = var.eks_node_desired_size # 희망 노드 수
}

# ==============================================================================
# Prod VPC (EKS) 보안 그룹 규칙 (Prod VPC (EKS) Security Group Rules)
# Shared VPC로부터의 통신을 허용합니다. (Allow communication from Shared VPC.)
# ==============================================================================

# EKS 클러스터 보안 그룹에 Shared VPC CIDR로부터의 인바운드 규칙 추가
# EKS 클러스터의 API 서버 등과 통신이 필요할 수 있습니다.
resource "aws_security_group_rule" "allow_shared_from_cluster_sg" {
  type              = "ingress"
  from_port         = 0           # 모든 포트 (또는 특정 포트 지정) (All ports or specific ports)
  to_port           = 65535       # 모든 포트 (All ports)
  protocol          = "tcp"       # TCP (또는 "all" for all protocols)
  cidr_blocks       = [var.shared_vpc_cidr_block] # Shared VPC CIDR
  security_group_id = module.eks_cluster.eks_cluster_security_group_id # EKS 클러스터 보안 그룹 ID
  description       = "Allow all TCP from Shared VPC CIDR to EKS Cluster SG"
}

# EKS 노드 그룹 보안 그룹에 Shared VPC CIDR로부터의 인바운드 규칙 추가
# EKS 파드 및 노드에 대한 통신이 필요할 수 있습니다.
resource "aws_security_group_rule" "allow_shared_from_node_sg" {
  type              = "ingress"
  from_port         = 0           # 모든 포트 (All ports)
  to_port           = 65535       # 모든 포트 (All ports)
  protocol          = "tcp"       # TCP (또는 "all")
  cidr_blocks       = [var.shared_vpc_cidr_block] # Shared VPC CIDR
  security_group_id = module.eks_cluster.eks_node_security_group_id # EKS 노드 그룹 보안 그룹 ID
  description       = "Allow all TCP from Shared VPC CIDR to EKS Node SG"
}


# 4. VPC 피어링 연결 (VPC Peering Connection)
# 새로 생성된 Prod VPC와 기존 Shared VPC 간의 피어링 연결을 생성합니다.
resource "aws_vpc_peering_connection" "prod_to_shared" {
  peer_vpc_id = var.shared_vpc_id # Shared VPC ID (변수로 전달받음)
  vpc_id      = module.prod_vpc.vpc_id # 새로 생성된 Prod VPC ID
  auto_accept = true # 양쪽 VPC가 동일한 AWS 계정에 있다면 true로 설정합니다.

  tags = {
    Name = "prod-shared-vpc-peering"
  }
}

# 5. Prod VPC 라우팅 테이블 업데이트 (Update Prod VPC Route Tables)
# Prod VPC의 프라이빗 라우팅 테이블에 Shared VPC로의 경로를 추가합니다.
resource "aws_route" "prod_private_to_shared" {
  count                     = length(module.prod_vpc.private_route_table_ids)
  route_table_id            = module.prod_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.shared_vpc_cidr_block # Shared VPC CIDR (변수로 전달받음)
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_to_shared.id
}

# ==============================================================================
# Argo CD 설치를 위한 Terraform 리소스 (Terraform Resources for Argo CD Installation)
# ==============================================================================

# Argo CD를 위한 Kubernetes Namespace 생성 (Create Kubernetes Namespace for Argo CD)
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  # Kubernetes Provider가 EKS 클러스터가 완전히 준비될 때까지 기다리도록 의존성을 명시합니다.
  depends_on = [
    module.eks_cluster, # <<<< 이 부분을 수정했습니다. (This line has been modified.)
  ]
}

# Argo CD Helm Chart 설치 (Install Argo CD Helm Chart)
# 공식 Argo CD Helm 차트를 사용하여 Argo CD를 클러스터에 배포합니다.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name # 생성된 argocd 네임스페이스에 배포
  version    = "6.6.0" # Argo CD Helm 차트 버전 (최신 안정 버전을 확인하고 사용하세요) (Check and use the latest stable version)

  # values: Helm 차트의 기본값을 오버라이드합니다. (Override default Helm chart values.)
  # Argo CD 서버를 ClusterIP 타입으로 노출하여 외부 로드 밸런서를 생성하지 않습니다.
  values = [
    <<-EOF
    server:
      service:
        type: ClusterIP # LoadBalancer 대신 ClusterIP 사용 (Use ClusterIP instead of LoadBalancer)
    EOF
  ]

  # EKS 클러스터가 완전히 준비된 후에 Argo CD가 설치되도록 의존성 설정 (Set dependency so Argo CD is installed only after EKS cluster is fully ready)
  depends_on = [
    kubernetes_namespace.argocd, # Argo CD 네임스페이스가 먼저 생성되어야 합니다.
  ]
}

# (Optional) Argo CD UI 접근을 위한 초기 admin 비밀번호 가져오기 (Get initial admin password for Argo CD UI access)
# 이 값을 Terraform Output으로 노출하여 쉽게 접근할 수 있습니다.
data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd] # Argo CD가 설치된 후에 시크릿이 생성됩니다. (Secret is created after Argo CD is installed.)
}
