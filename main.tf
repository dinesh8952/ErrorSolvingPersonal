provider "aws" {
  alias  = "region_a"
  region = "us-west-1"
}

provider "aws" {
  alias  = "region_b"
  region = "us-west-2"
}

# Create VPCs
resource "aws_vpc" "vpc_a" {
  provider = aws.region_a
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-a"
  }
}

resource "aws_vpc" "vpc_b" {
  provider = aws.region_b
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "vpc-b"
  }
}

# Create VPC Peering Connection
resource "aws_vpc_peering_connection" "peer_vpc" {
  provider = aws.region_a
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id  = aws_vpc.vpc_b.id
  peer_region  = "us-west-2"

  tags = {
    Name = "vpc-peer-connection"
  }
}

# Update Route Tables for VPC A
resource "aws_route" "route_to_vpc_b" {
  provider = aws.region_a
  route_table_id         = aws_vpc.vpc_a.default_route_table_id
  destination_cidr_block = aws_vpc.vpc_b.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_vpc.id
}

# Update Route Tables for VPC B
resource "aws_route" "route_to_vpc_a" {
  provider = aws.region_b
  route_table_id         = aws_vpc.vpc_b.default_route_table_id
  destination_cidr_block = aws_vpc.vpc_a.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_vpc.id
}

