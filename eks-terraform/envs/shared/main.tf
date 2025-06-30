# AWS Provider 설정 (AWS Provider Configuration)
provider "aws" {
  region = var.aws_region # variables.tf에 정의된 AWS 리전 사용
}

# 기존 Shared VPC 조회 (Lookup Existing Shared VPC)
data "aws_vpc" "existing_shared" {
  id = var.shared_vpc_id # env/shared/variables.tf에서 전달받은 기존 Shared VPC ID
}

# Shared VPC 라우팅 테이블에 Prod VPC (EKS)로의 경로 추가 (Add Route to Prod VPC in Shared RT)
# 명시적으로 전달받은 프라이빗 라우팅 테이블 ID 목록에 경로를 추가합니다.
resource "aws_route" "shared_private_to_prod_route" {
  count                     = length(var.shared_private_route_table_ids) # 변수로 전달받은 RT ID 개수만큼 생성
  route_table_id            = var.shared_private_route_table_ids[count.index] # 명시된 RT ID 사용
  destination_cidr_block    = var.prod_vpc_cidr_block # Prod VPC CIDR (외부에서 입력받음)
  vpc_peering_connection_id = var.vpc_peering_connection_id # 피어링 연결 ID (외부에서 입력받음)

  # 라우팅 테이블에 이미 동일한 목적지 CIDR 블록이 존재하면 오류를 방지하기 위해 ignore_changes 사용
  lifecycle {
    ignore_changes = [
      destination_cidr_block,
    ]
  }
}
