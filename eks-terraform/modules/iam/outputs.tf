# EKS 클러스터 IAM 역할 ARN (EKS Cluster IAM Role ARN)
output "eks_cluster_iam_role_arn" {
  description = "ARN of the IAM role for the EKS cluster" # EKS 클러스터용 IAM 역할 ARN
  value       = aws_iam_role.eks_cluster.arn
}

# EKS 노드 IAM 역할 ARN (EKS Node IAM Role ARN)
output "eks_node_iam_role_arn" {
  description = "ARN of the IAM role for the EKS worker nodes" # EKS 워커 노드용 IAM 역할 ARN
  value       = aws_iam_role.eks_node.arn
}

# EBS CSI IAM 역할 ARN (EBS CSI IAM Role ARN)
output "eks_ebs_csi_iam_role_arn" {
  description = "ARN of the IAM role for the EBS CSI driver" # EBS CSI 드라이버용 IAM 역할 ARN
  value       = aws_iam_role.ebs_csi.arn
}
