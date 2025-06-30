# EKS 클러스터 생성 (Create EKS Cluster)
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name # 클러스터 이름
  role_arn = var.eks_cluster_iam_role_arn # EKS 클러스터 IAM 역할 ARN
  version  = var.cluster_version # Kubernetes 버전

  vpc_config {
    subnet_ids         = var.subnet_ids # EKS 클러스터가 배포될 서브넷 ID 목록
    endpoint_private_access = true # Private Endpoint 접근 활성화 (Enable Private Endpoint Access)
    endpoint_public_access  = true  # Public Endpoint 접근 활성화 (Enable Public Endpoint Access)
    # security_group_ids = [aws_security_group.eks_cluster.id] # EKS 컨트롤 플레인 보안 그룹
  }

  depends_on = [
    var.eks_cluster_iam_role_arn, # IAM 역할이 먼저 생성되어야 합니다.
  ]

  tags = {
    Name = var.cluster_name
  }
}

# EKS 노드 그룹 생성 (Create EKS Node Group)
# Spot 인스턴스를 사용하는 노드 그룹입니다.
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name # EKS 클러스터 이름
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.eks_node_iam_role_arn # EKS 노드 IAM 역할 ARN
  subnet_ids      = var.subnet_ids # 노드 그룹이 배포될 서브넷 ID 목록
  instance_types  = [var.instance_type] # t3.medium 인스턴스 타입

  scaling_config {
    min_size     = var.min_size # 최소 노드 수
    max_size     = var.max_size # 최대 노드 수
    desired_size = var.desired_size # 희망 노드 수
  }

  # Spot 인스턴스 사용을 명시합니다. (Specify using Spot instances)
  capacity_type = var.capacity_type # "SPOT"

  # Spot 인스턴스 중단 동작 설정 (Set Spot instance interruption behavior)
  # 기본값은 "terminate"이며, 인스턴스 중단 시 종료됩니다.
  # launch_template {
  #   name_prefix = "${var.cluster_name}-spot-lt-"
  #   version     = "$Latest"
  # }

  remote_access {
    ec2_ssh_key = "" # SSH 접속을 위한 키 페어 (필요 시 지정) (Specify key pair for SSH access if needed)
    source_security_group_ids = [] # SSH 접근 허용할 보안 그룹 (필요 시 지정)
  }

  # 노드 그룹이 클러스터에 조인하기 위한 보안 그룹 규칙을 생성합니다.
  # 이것은 클러스터 생성 후 자동 생성되는 EKS 관리 보안 그룹에 포함될 수 있습니다.
  # 여기서는 명시적으로 추가하지 않고, EKS 기본 동작을 따릅니다.

  depends_on = [
    aws_eks_cluster.main, # 클러스터가 먼저 생성되어야 합니다.
    var.eks_node_iam_role_arn, # IAM 역할이 먼저 생성되어야 합니다.
  ]

  tags = {
    Name = "${var.cluster_name}-node-group"
  }
}

# EBS CSI 드라이버 애드온 배포 (Deploy EBS CSI Driver Addon)
# AWS EBS CSI 드라이버는 EKS 클러스터에서 동적 볼륨 프로비저닝을 가능하게 합니다.
resource "aws_eks_addon" "ebs_csi" {
  cluster_name          = aws_eks_cluster.main.name # EKS 클러스터 이름
  addon_name            = "aws-ebs-csi-driver" # 애드온 이름
  addon_version         = "v1.27.0-eksbuild.1" # 드라이버 버전 (EKS 클러스터 버전에 맞춰 조정)
  service_account_role_arn = var.ebs_csi_iam_role_arn # EBS CSI 드라이버용 IAM 역할 ARN
  
  depends_on = [
    aws_eks_cluster.main, # EKS 클러스터가 먼저 생성되어야 합니다.
    var.ebs_csi_iam_role_arn, # IAM 역할이 먼저 생성되어야 합니다.
  ]
}

# Kubeconfig 생성을 위한 data 리소스 (Data resource for Kubeconfig generation)
# aws_eks_cluster_auth는 kubectl이 클러스터에 인증하는 데 필요한 토큰을 가져옵니다.
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

# Kubeconfig 파일 내용 (Kubeconfig file content)
# 로컬에서 kubectl을 사용하여 클러스터에 접근하기 위한 설정입니다.
resource "local_file" "kubeconfig" {
  content  = <<EOT
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${aws_eks_cluster.main.certificate_authority.0.data}
    server: ${aws_eks_cluster.main.endpoint}
  name: ${aws_eks_cluster.main.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.main.name}
    user: ${aws_eks_cluster.main.name}
  name: ${aws_eks_cluster.main.name}
current-context: ${aws_eks_cluster.main.name}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.main.name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${aws_eks_cluster.main.name}"
        - "--region"
        - "${data.aws_region.current.name}"
      # env:
      #   - name: AWS_PROFILE
      #     value: "your-aws-profile-name" # 필요 시 AWS CLI 프로필 지정 (Specify AWS CLI profile if needed)
EOT
  filename = "${path.module}/kubeconfig_${var.cluster_name}" # 현재 모듈 디렉토리에 kubeconfig 파일 생성
}

# 현재 AWS 리전 정보 가져오기 (Get current AWS Region info)
data "aws_region" "current" {}
