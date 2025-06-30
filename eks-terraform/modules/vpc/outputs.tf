# VPC ID (VPC ID)
output "vpc_id" {
  description = "The ID of the VPC" # VPC의 ID
  value       = aws_vpc.main.id
}

# Public 서브넷 ID 목록 (Public Subnet IDs)
output "public_subnet_ids" {
  description = "List of public subnet IDs" # Public 서브넷 ID 목록
  value       = [for s in aws_subnet.public : s.id]
}

# Private 서브넷 ID 목록 (Private Subnet IDs)
output "private_subnet_ids" {
  description = "List of private subnet IDs" # Private 서브넷 ID 목록
  value       = [for s in aws_subnet.private : s.id]
}

# Database 서브넷 ID 목록 (Database Subnet IDs)
output "database_subnet_ids" {
  description = "List of database subnet IDs" # Database 서브넷 ID 목록
  value       = [for s in aws_subnet.database : s.id]
}

# Public 라우팅 테이블 ID (Public Route Table ID)
output "public_route_table_id" {
  description = "The ID of the public route table" # Public 라우팅 테이블의 ID
  value       = aws_route_table.public.id
}

# Private 라우팅 테이블 ID 목록 (Private Route Table IDs)
output "private_route_table_ids" {
  description = "List of private route table IDs" # Private 라우팅 테이블 ID 목록
  value       = [for r in aws_route_table.private : r.id]
}

# 인터넷 게이트웨이 ID (Internet Gateway ID)
output "igw_id" {
  description = "The ID of the Internet Gateway" # 인터넷 게이트웨이의 ID
  value       = aws_internet_gateway.main.id
}
