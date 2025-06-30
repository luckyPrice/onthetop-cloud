# EKS 클러스터 IAM 역할 (EKS Cluster IAM Role)
# EKS 컨트롤 플레인이 AWS 리소스를 관리하는 데 사용됩니다.
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# EKS 클러스터 역할 정책 연결 (EKS Cluster Role Policy Attachment)
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS VPC 리소스 컨트롤러 정책 연결 (EKS VPC Resource Controller Policy Attachment)
# 클러스터의 ELB, ENI 등을 관리하는 데 필요합니다.
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# EKS 노드 그룹 IAM 역할 (EKS Node Group IAM Role)
# EKS 워커 노드(EC2 인스턴스)가 EKS에 조인하고 AWS 리소스에 접근하는 데 사용됩니다.
resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# EKS 워커 노드 정책 연결 (EKS Worker Node Policy Attachment)
resource "aws_iam_role_policy_attachment" "eks_node_worker_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# ECR 읽기 전용 정책 연결 (ECR Read-Only Policy Attachment)
# 워커 노드가 ECR에서 컨테이너 이미지를 가져올 수 있도록 합니다.
resource "aws_iam_role_policy_attachment" "eks_node_ecr_read_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS CNI 정책 연결 (EKS CNI Policy Attachment)
# EKS 워커 노드의 네트워크 인터페이스 관리를 위한 CNI(Container Network Interface) 플러그인에 필요합니다.
resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# OIDC 제공자 (OpenID Connect Provider)
# EKS 워커 노드의 서비스 계정이 AWS IAM 역할을 수임할 수 있도록 합니다.
# 주로 EBS CSI 드라이버와 같은 Kubernetes 애드온에 사용됩니다.
resource "aws_iam_openid_connect_provider" "eks" {
  url = var.oidc_provider_url
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a99905ad16769c279c13be6a77e774f9d"] # AWS OIDC thumbprint (일반적으로 변경되지 않음)
}

# EBS CSI 드라이버 IAM 역할 (EBS CSI Driver IAM Role)
# Kubernetes Persistent Volume(PV) 및 Persistent Volume Claim(PVC)을 위해 EBS 볼륨을 관리합니다.
resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      },
    ]
  })
}

# EBS CSI 드라이버 IAM 정책 (EBS CSI Driver IAM Policy)
resource "aws_iam_policy" "ebs_csi_policy" {
  name        = "${var.cluster_name}-ebs-csi-policy"
  description = "IAM policy for EBS CSI driver" # EBS CSI 드라이버용 IAM 정책

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateVolume",
          "ec2:DeleteVolume",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumeStatus",
          "ec2:ModifyVolume",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeTags",
        ]
        Resource = "*"
      },
    ]
  })
}

# EBS CSI 드라이버 정책 연결 (EBS CSI Driver Policy Attachment)
resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = aws_iam_policy.ebs_csi_policy.arn
}
