# AWS 리전 (AWS Region)
variable "aws_region" {
  description = "AWS Region to deploy resources" # 리소스를 배포할 AWS 리전
  type        = string
  default     = "ap-northeast-2" # 서울 리전
}

# 가용 영역 (Availability Zones)
# 이 파일에서는 직접 사용되지 않지만, 다른 모듈에서 필요할 수 있으므로 유지합니다.
variable "azs" {
  description = "List of Availability Zones to use for VPC subnets" # VPC 서브넷에 사용할 가용 영역 목록
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
}

# Shared VPC ID (Shared VPC ID)
# 사용할 기존 Shared VPC의 ID를 입력하세요. (Input the ID of the existing Shared VPC to use.)
variable "shared_vpc_id" {
  description = "The ID of the existing Shared VPC" # 기존 Shared VPC의 ID
  type        = string
  default     = "vpc-06ab5451f12784644" # 이미지에서 확인된 kubeadm-shared VPC ID (kubeadm-shared VPC ID confirmed from image)
}

# Shared VPC Private 라우팅 테이블 ID 목록 (Shared VPC Private Route Table IDs)
# 기존 Shared VPC의 Private 라우팅 테이블 ID들을 여기에 입력해야 합니다.
# AWS 콘솔에서 해당 VPC의 Private Subnet에 연결된 라우팅 테이블들을 확인하세요.
variable "shared_private_route_table_ids" {
  description = "List of existing private route table IDs in the Shared VPC to add routes to." # Shared VPC의 기존 Private 라우팅 테이블 ID 목록 (경로 추가용)
  type        = list(string)
  # 이 부분에 실제 라우팅 테이블 ID를 입력
  default = ["rtb-027a5b03d4f661ef4"] # 실제 ID로 교체해야 합니다. (MUST be replaced with actual IDs.)
}

# Prod VPC CIDR 블록 (Prod VPC CIDR Block)
# Prod 환경의 CIDR 블록을 입력받아야 합니다.
variable "prod_vpc_cidr_block" {
  description = "The CIDR block of the Prod VPC for routing" # 라우팅을 위한 Prod VPC의 CIDR 블록
  type        = string
  default     = "10.20.0.0/16" # 새로 생성될 Prod VPC의 CIDR (New Prod VPC CIDR)
}

# VPC 피어링 연결 ID (VPC Peering Connection ID)
# Prod 환경에서 생성된 피어링 연결 ID를 입력받아야 합니다.
variable "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection from Prod to Shared VPC" # Prod에서 Shared VPC로의 VPC 피어링 연결 ID
  type        = string
  # 이 변수는 Shared 환경을 두 번째로 apply할 때 Prod 환경의 출력값으로 채워집니다.
}
