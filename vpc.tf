#vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "My VPC"
  }

  enable_dns_hostnames = true
}

# public subnet
resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.my_vpc,
  ]

  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "Public Subnet"
  }

  map_public_ip_on_launch = true
}

# private subnet
resource "aws_subnet" "nated" {
  depends_on = [
    aws_vpc.my_vpc,
  ]
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone

  tags = {
    Name = "NAT-ed Subnet"
  }
}

# internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.my_vpc,
  ]

  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

# route table with target as internet gateway
resource "aws_route_table" "IG_route_table" {
  depends_on = [
    aws_vpc.my_vpc,
    aws_internet_gateway.internet_gateway,
  ]

  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Main Route Table"
  }
}

# associate route table to public subnet
resource "aws_route_table_association" "associate_routetable_to_public_subnet" {
  depends_on = [
    aws_subnet.public,
    aws_route_table.IG_route_table,
  ]
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.IG_route_table.id
}

# elastic ip
resource "aws_eip" "elastic_ip" {
  vpc = true
}

# NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [
    aws_subnet.public,
    aws_eip.elastic_ip,
  ]
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-gateway"
  }
}

# route table with target as NAT gateway
resource "aws_route_table" "NAT_route_table" {
  depends_on = [
    aws_vpc.my_vpc,
    aws_nat_gateway.nat_gateway,
  ]

  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  depends_on = [
    aws_subnet.nated,
    aws_route_table.NAT_route_table,
  ]
  subnet_id      = aws_subnet.nated.id
  route_table_id = aws_route_table.NAT_route_table.id
}