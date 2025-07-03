# AWS Provider 설정 (AWS Provider Configuration)
provider "aws" {
  region = var.aws_region # variables.tf에 정의된 AWS 리전 사용
}
data "aws_eks_cluster_auth" "main" {
  name = module.eks_cluster.cluster_name
}
# Kubernetes Provider 설정 (Kubernetes Provider Configuration)
# Terraform이 EKS 클러스터와 통신하기 위해 필요합니다.
# EKS 클러스터 모듈의 출력값을 사용합니다.
provider "kubernetes" {
  # host 설정을 EKS 클러스터 엔드포인트로 명시적으로 지정하고,
  # EKS 클러스터 자체가 준비될 때까지 기다리도록 의존성을 추가합니다.
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.main.token

  # EKS 클러스터가 완전히 Active 상태가 될 때까지 Provider가 초기화되지 않도록 의존성을 명시합니다.
  # This dependency ensures the Kubernetes provider waits for the EKS cluster to be active.
}

# Helm Provider 설정 (Helm Provider Configuration)
# Terraform이 Helm 차트를 사용하여 Kubernetes에 애플리케이션을 배포하기 위해 필요합니다.
# Kubernetes Provider에 의존합니다.
provider "helm" {
  kubernetes = { # <--- 등호(=)를 추가하여 인수로 변경
    host                   = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

# 1. Prod VPC 모듈 호출 (Calling the Prod VPC Module)
# EKS 클러스터가 배포될 Prod VPC를 생성합니다.
module "prod_vpc" {
  source = "../../modules/vpc" # vpc 모듈 경로 (상대 경로 조정)
  name   = "prod"
  cidr_block = var.prod_vpc_cidr_block # 10.10.0.0/16
  azs        = var.azs # 가용 영역 목록
  # 각 서브넷의 CIDR 블록을 정의합니다. (Define CIDR blocks for each subnet)
  public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
  private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
  database_subnet_cidrs = ["10.20.20.0/28", "10.20.20.16/28"]

  # EKS 워커 노드가 인터넷에 접근할 수 있도록 NAT Gateway를 활성화합니다.
  enable_nat_gateway = true
}

# 2. IAM 모듈 호출 (Calling the IAM Module)
# EKS 클러스터, 노드 그룹 및 EBS CSI 드라이버에 필요한 IAM 역할을 생성합니다.
module "iam" {
  source = "../../modules/iam" # iam 모듈 경로 (상대 경로 조정)
  cluster_name = var.eks_cluster_name # EKS 클러스터 이름
  # EKS 클러스터의 OIDC Provider URL을 사용하여 EBS CSI 드라이버 역할.
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  oidc_provider_url = module.eks_cluster.oidc_provider_url
}

# ==============================================================================
# EKS 노드 그룹을 위한 전용 보안 그룹 생성 (Create Dedicated Security Group for EKS Node Group)
# ==============================================================================
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.eks_cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.prod_vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = [module.prod_vpc.vpc_cidr_block] # Allow all internal VPC traffic
    description = "Allow all internal VPC traffic"
  }

  # Shared VPC로부터의 모든 TCP 트래픽 허용 (Allow all TCP traffic from Shared VPC)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.shared_vpc_cidr_block]
    description = "Allow all TCP from Shared VPC CIDR to EKS Node SG"
  }

  # EKS 컨트롤 플레인으로부터의 인바운드 규칙 (EKS Control Plane inbound rules)
  # EKS 클러스터 보안 그룹 (cluster_security_group_id)으로부터의 트래픽을 허용합니다.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    security_groups = [module.eks_cluster.eks_cluster_security_group_id]
    description = "Allow all traffic from EKS Cluster SG"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.eks_cluster_name}-node-sg"
    # EKS가 노드 그룹을 인식하도록 태그 추가 (Add tags for EKS to recognize the node group)
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# 3. EKS 모듈 호출 (Calling the EKS Module)
# Prod VPC 내에 EKS 클러스터 및 노드 그룹을 생성합니다.
module "eks_cluster" {
  source = "../../modules/eks" # eks 모듈 경로 (상대 경로 조정)
  cluster_name = var.eks_cluster_name # EKS 클러스터 이름
  cluster_version = var.eks_cluster_version # Kubernetes 버전
  vpc_id = module.prod_vpc.vpc_id # EKS를 Prod VPC에 배포
  subnet_ids = module.prod_vpc.private_subnet_ids # Prod VPC의 private 서브넷 사용
  # EKS 클러스터 및 노드 그룹에 필요한 IAM 역할 ARN을 전달합니다.
  eks_cluster_iam_role_arn = module.iam.eks_cluster_iam_role_arn
  eks_node_iam_role_arn    = module.iam.eks_node_iam_role_arn
  ebs_csi_iam_role_arn     = module.iam.eks_ebs_csi_iam_role_arn
  aws_region               = var.aws_region

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
  description       = "Allow all TCP from Shared VPC CIDR to EKS Cluster SG (v3)"
}

resource "aws_vpc_peering_connection" "prod_to_shared" {
  peer_vpc_id = var.shared_vpc_id # Shared VPC ID (변수로 전달받음)
  vpc_id      = module.prod_vpc.vpc_id # 새로 생성된 Prod VPC ID
  auto_accept = true # 양쪽 VPC가 동일한 AWS 계정에 있다면 true로 설정합니다.

  tags = {
    Name = "prod-shared-vpc-peering"
  }
}

resource "aws_route" "prod_private_to_shared" {
  count                     = length(module.prod_vpc.private_route_table_ids)
  route_table_id            = module.prod_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.shared_vpc_cidr_block # Shared VPC CIDR (변수로 전달받음)
  vpc_peering_connection_id = aws_vpc_peering_connection.prod_to_shared.id
}

# ==============================================================================
# Argo CD 설치
# ==============================================================================
# null_resource를 사용하여 aws-auth ConfigMap을 자동으로 패치합니다.
# 이 리소스는 EKS 클러스터가 완전히 준비된 후에 kubectl 명령을 실행하여
# Terraform 실행 사용자에게 클러스터 관리자 권한을 부여합니다.
# aws-auth ConfigMap 패치에 사용할 JSON 파일 생성 (Create JSON file for aws-auth ConfigMap patch)

resource "local_file" "aws_auth_patch_json" {
  content  = jsonencode({
    data = {
      # mapUsers 내용을 YAML 문자열로 정의합니다.
      # YAML 문자열은 들여쓰기가 중요하므로, EOT 블록을 사용하여 그대로 삽입합니다.
      mapUsers = <<-EOT
        - userarn: ${data.aws_caller_identity.current.arn}
          username: terraform-admin
          groups:
            - system:masters
      EOT
    }
  })
  filename = "${path.module}/aws-auth-patch.json" # 현재 모듈 디렉토리에 파일 생성 (Create file in current module directory)
}


resource "null_resource" "aws_auth_patch" {
  # EKS 클러스터와 노드 그룹이 완전히 Active 상태가 될 때까지 기다립니다.
  depends_on = [
    module.eks_cluster,
  ]

  # EKS 클러스터 이름과 리전을 트리거로 사용하여, 클러스터 정보가 변경될 때마다 재실행되도록 합니다.
  triggers = {
    cluster_name = module.eks_cluster.cluster_name
    cluster_region = var.aws_region
    patch_content_hash = local_file.aws_auth_patch_json.content # <<<< 이 부분을 수정했습니다. (This part has been modified.)
  }

  provisioner "local-exec" {
    # aws eks update-kubeconfig 명령을 실행하여 kubectl 설정을 업데이트합니다.
    command = "aws eks update-kubeconfig --region ${self.triggers.cluster_region} --name ${self.triggers.cluster_name}"
    # 명령 실행 실패 시 Terraform apply가 실패하도록 합니다.
    on_failure = fail
  }

  provisioner "local-exec" {
    # kubectl이 클러스터에 연결될 수 있도록 잠시 대기합니다.
    # EKS 클러스터가 ACTIVE 상태가 되어도 API 서버가 완전히 준비되는 데 시간이 걸릴 수 있습니다.
    command = "sleep 30"
  }

  provisioner "local-exec" {
    # aws-auth ConfigMap을 패치하여 Terraform 실행 사용자에게 system:masters 권한을 부여합니다.
    # --patch-file 플래그를 사용하여 JSON 파일을 전달합니다.
    # kubectl patch 명령이 실패할 경우 재시도하도록 루프를 추가합니다. (Add loop to retry kubectl patch command on failure.)
    command = <<-EOT
      MAX_RETRIES=5
      RETRY_COUNT=0
      until kubectl patch configmap -n kube-system aws-auth --patch-file ${local_file.aws_auth_patch_json.filename}; do
        if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
          echo "Failed to patch aws-auth ConfigMap after $MAX_RETRIES retries."
          exit 1
        fi
        echo "Retrying kubectl patch... ($((RETRY_COUNT + 1))/$MAX_RETRIES)"
        sleep 10
        RETRY_COUNT=$((RETRY_COUNT + 1))
      done
    EOT
    # 명령 실행 실패 시 Terraform apply가 실패하도록 합니다。
    on_failure = fail
  }
}

# 현재 AWS CLI 사용자(Terraform 실행 사용자)의 ARN을 가져오는 데이터 소스
data "aws_caller_identity" "current" {}

# Argo CD를 위한 Kubernetes Namespace 생성 (Create Kubernetes Namespace for Argo CD)
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  # Kubernetes Provider가 EKS 클러스터가 완전히 준비되고 aws-auth가 패치될 때까지 기다리도록 의존성을 명시합니다.
  depends_on = [
    null_resource.aws_auth_patch, # aws-auth ConfigMap 패치가 완료된 후
  ]
}

# Argo CD Helm Chart 설치 (Install Argo CD Helm Chart)
# 공식 Argo CD Helm 차트를 사용하여 Argo CD를 클러스터에 배포.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name # 생성된 argocd 네임스페이스에 배포
  version    = "6.6.0" # Argo CD Helm 차트 버전 (최신 안정 버전을 확인하고 사용하세요) (Check and use the latest stable version)

  # values: Helm 차트의 기본값을 오버라이드합니다. (Override default Helm chart values.)
  # 여기서는 Argo CD 서버를 LoadBalancer 타입으로 노출하여 외부에서 접근 가능하게 합니다.
  values = [
    <<-EOF
    server:
      service:
        type: LoadBalancer # LoadBalancer 사용 (Use LoadBalancer)
        annotations:
          # AWS ALB를 사용하도록 어노테이션 추가 (Add annotations to use AWS ALB)
          service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing # 인터넷향 로드 밸런서 (Internet-facing LB)
          service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${data.aws_acm_certificate.argocd_cert_lookup.arn}" # ACM 인증서 ARN
          service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443" # 443 포트에서 SSL 사용 (Use SSL on port 443)
          service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "HTTPS" # 백엔드 프로토콜 HTTPS (Backend protocol HTTPS)
          service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: "/healthz" # 헬스체크 경로 (Health check path)
          service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "8080" # 헬스체크 포트 (Argo CD Ingress default is 8080)
          service.beta.kubernetes.io/aws-load-balancer-target-group-attributes: "stickiness.enabled=true,stickiness.type=lb_cookie" # 세션 스티키니스 (Session stickiness)
          service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance" # NLB 타겟 타입 (Instance target type for NLB)
          # ALB를 사용하려면 service.beta.kubernetes.io/aws-load-balancer-type: "alb"
          # NLB를 사용하려면 service.beta.kubernetes.io/aws-load-balancer-type: "nlb" (기본값은 ALB)
          # 여기서는 NLB를 명시적으로 지정하여 TLS 종료를 ALB가 아닌 NLB가 하도록 설정합니다.
          # If using NLB, TLS termination is done by NLB, not ALB.
          # service.beta.kubernetes.io/aws-load-balancer-type: "nlb" # NLB 타입 명시
    EOF
  ]

  # EKS 클러스터가 완전히 준비된 후에 Argo CD가 설치되도록 의존성 설정 (Set dependency so Argo CD is installed only after EKS cluster is fully ready)
  depends_on = [
    kubernetes_namespace.argocd, # Argo CD 네임스페이스가 먼저 생성되어야 합니다.
  ]
}

# Helm으로 배포된 Argo CD 서버 서비스의 정보를 읽어오는 데이터 소스
data "kubernetes_service" "argocd_server" {
  metadata {
    # Argo CD Helm 차트가 생성하는 기본 서비스 이름
    name      = "argocd-server" 
    # Argo CD를 설치한 네임스페이스
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  # Helm 릴리스가 완료되어 서비스가 생성된 후에 이 데이터를 읽도록 의존성을 명시합니다.
  # 이렇게 하지 않으면 서비스가 생성되기도 전에 정보를 읽으려다 에러가 발생할 수 있습니다.
  depends_on = [helm_release.argocd]
}
# ===============================================================

# (Optional) Argo CD UI 접근을 위한 초기 admin 비밀번호 가져오기 (Get initial admin password for Argo CD UI access)
# 이 값을 Terraform Output으로 노출하여 쉽게 접근할 수 있습니다.
data "kubernetes_secret" "argocd_initial_admin_secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd] # Argo CD가 설치된 후에 시크릿이 생성됩니다. (Secret is created after Argo CD is installed.)
}