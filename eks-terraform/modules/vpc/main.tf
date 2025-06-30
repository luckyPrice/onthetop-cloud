# VPC 생성 (Create VPC)
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block # VPC의 CIDR 블록
  tags = {
    Name = "${var.name}-vpc"
  }
}

# 인터넷 게이트웨이 생성 (Create Internet Gateway)
# Public 서브넷이 인터넷과 통신할 수 있도록 합니다.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-igw"
  }
}

# Public 서브넷 생성 (Create Public Subnets)
# 각 가용 영역(AZ)에 Public 서브넷을 생성합니다.
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true # Public IP 자동 할당
  tags = {
    Name = "${var.name}-public-subnet-${count.index + 1}"
  }
}

# Private 서브넷 생성 (Create Private Subnets)
# 각 가용 영역(AZ)에 Private 서브넷을 생성합니다.
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.name}-private-subnet-${count.index + 1}"
  }
}

# Database 서브넷 생성 (Create Database Subnets)
# 각 가용 영역(AZ)에 Database 서브넷을 생성합니다.
resource "aws_subnet" "database" {
  count             = length(var.database_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.name}-database-subnet-${count.index + 1}"
  }
}

# Public 라우팅 테이블 생성 (Create Public Route Table)
# Public 서브넷의 트래픽을 인터넷 게이트웨이로 라우팅합니다.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-public-rtb"
  }
}

# Public 라우팅 테이블에 인터넷 게이트웨이 경로 추가 (Add Internet Gateway Route to Public Route Table)
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public 서브넷과 Public 라우팅 테이블 연결 (Associate Public Subnets with Public Route Table)
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway 생성 (Create NAT Gateway)
# Private 서브넷이 인터넷으로 나가는 트래픽을 처리합니다. (enable_nat_gateway 변수가 true일 때만 생성)
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  tags = {
    Name = "${var.name}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # Public 서브넷에 NAT Gateway 배치
  tags = {
    Name = "${var.name}-nat-gw-${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.main] # IGW가 먼저 생성되어야 합니다.
}

# Private 라우팅 테이블 생성 (Create Private Route Tables)
# 각 AZ의 Private 서브넷에 연결될 라우팅 테이블을 생성합니다.
resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-private-rtb-${count.index + 1}"
  }
}

# Private 라우팅 테이블에 NAT Gateway 경로 추가 (Add NAT Gateway Route to Private Route Tables)
resource "aws_route" "private_nat_gateway" {
  count                  = var.enable_nat_gateway ? length(aws_route_table.private) : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id # 각 AZ의 NAT Gateway 사용
}

# Private 서브넷과 Private 라우팅 테이블 연결 (Associate Private Subnets with Private Route Tables)
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Database 라우팅 테이블 생성 (Create Database Route Tables)
# 각 AZ의 Database 서브넷에 연결될 라우팅 테이블을 생성합니다.
resource "aws_route_table" "database" {
  count  = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.name}-database-rtb-${count.index + 1}"
  }
}

# Database 서브넷과 Database 라우팅 테이블 연결 (Associate Database Subnets with Database Route Tables)
resource "aws_route_table_association" "database" {
  count          = length(aws_subnet.database)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[count.index].id
}

