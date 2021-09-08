resource "aws_vpc" "pro-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "terraform-vpc"
  }
}


resource "aws_internet_gateway" "pro-ig" {
  vpc_id = aws_vpc.pro-vpc.id
  tags = {
    "Name" = "pro-ig"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.pro-vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    "Name" = "pro-pub-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.pro-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    "Name" = "pro-priv-subnet"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.pro-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pro-ig.id
  }
  tags = {
    "Name" = "ig_public_rt"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.pro-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.pro-nat-gw.id
  }
  tags = {
    "Name" = "nat_private_rt"
  }
}

resource "aws_route_table_association" "public-association" {
 subnet_id = aws_subnet.public-subnet.id
 route_table_id = aws_route_table.public-rt.id
}
 
resource "aws_route_table_association" "private-association" {
 subnet_id = aws_subnet.private-subnet.id
 route_table_id = aws_route_table.private-rt.id
}
resource "aws_eip" "pro-eip" {
  vpc = true
  tags = {
    "Name" = "pro-eip"
  }
}

resource "aws_eip" "pro-eip2" {
  vpc = true
  tags = {
    "Name" = "pro-eip2"
  }
}

resource "aws_eip_association" "project-eip2" {
  instance_id   = aws_instance.local-ec2.id
  allocation_id = aws_eip.pro-eip2.id
}

resource "aws_nat_gateway" "pro-nat-gw" {
  allocation_id = aws_eip.pro-eip.id
  subnet_id     = aws_subnet.private-subnet.id
  tags = {
    "Name" = "pro_nat_gw"
  }
}
