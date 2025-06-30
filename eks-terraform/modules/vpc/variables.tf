# VPC 이름 (VPC Name)
variable "name" {
  description = "The name for the VPC" # VPC 이름
  type        = string
}

# VPC CIDR 블록 (VPC CIDR Block)
variable "cidr_block" {
  description = "The CIDR block for the VPC" # VPC의 CIDR 블록
  type        = string
}

# 가용 영역 (Availability Zones)
variable "azs" {
  description = "List of Availability Zones to use for subnets" # 서브넷에 사용할 가용 영역 목록
  type        = list(string)
}

# Public 서브넷 CIDR 목록 (Public Subnet CIDRs)
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets" # Public 서브넷의 CIDR 블록 목록
  type        = list(string)
}

# Private 서브넷 CIDR 목록 (Private Subnet CIDRs)
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets" # Private 서브넷의 CIDR 블록 목록
  type        = list(string)
}

# Database 서브넷 CIDR 목록 (Database Subnet CIDRs)
variable "database_subnet_cidrs" {
  description = "List of CIDR blocks for the database subnets" # Database 서브넷의 CIDR 블록 목록
  type        = list(string)
}

# NAT Gateway 활성화 여부 (Enable NAT Gateway)
variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway in the VPC" # VPC에 NAT Gateway를 생성할지 여부
  type        = bool
  default     = true
}
