#Get AZ names based on number of subnets configured
locals {
  az_names = slice(data.aws_availability_zones.available.names, 0, length(var.subnets))
}

#Get available AZs
data "aws_availability_zones" "available" {}

#Main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_range
  enable_dns_support   = true
  enable_dns_hostnames = true
}

#Create public subnets
resource "aws_subnet" "public" {
  count             = length(var.subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

#Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

#Public subnets route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

#Create routes for each public subnet and set default route to IGW
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

#Associate public subnet route tables with public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}