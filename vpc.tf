data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc-app" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "igw-app" {
  vpc_id = aws_vpc.vpc-app.id

  tags = {
    Name = "igw-app"
  }
  depends_on = [
    aws_vpc.vpc-app
]
}

resource "aws_subnet" "public-subnet" {
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc-app.id
  cidr_block = element(var.public_cidr,count.index)
  map_public_ip_on_launch ="true"
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "public-${count.index+1}"
  }
}

resource "aws_subnet" "private-subnet"{
  count = length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.vpc-app.id
  cidr_block = element(var.private_cidr,count.index)
  availability_zone = element(data.aws_availability_zones.available.names,count.index)

  tags = {
    Name = "private-${count.index+1}"
  }
}

resource "aws_eip" "eip-nat" {
  vpc      = true
  tags = {
    Name = "eip-nat"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.public-subnet[0].id
  tags = {
    Name = "nat-gw"
  }
}

resource "aws_route_table" "public-routes" {
  vpc_id = aws_vpc.vpc-app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-app.id 
  }
  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table" "private-routes" {
  vpc_id = aws_vpc.vpc-app.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id 
  }
  tags = {
    Name = "private-route"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public-subnet[*].id)
  subnet_id      = element(aws_subnet.public-subnet[*].id,count.index)
  route_table_id = aws_route_table.public-routes.id
}

resource "aws_route_table_association" "private" {
  count=length(aws_subnet.private-subnet[*].id)
  subnet_id      = element(aws_subnet.private-subnet[*].id,count.index) 
  route_table_id = aws_route_table.private-routes.id
}