provider "aws" {
  region = "${var.region}"
}

# This is where we store the state
terraform {
  backend "s3" {
    bucket = "lobster1234-infrastructure"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

# We define the VPC here
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags{
    Name="My VPC in us-east-1"
  }
}

# We define a private subnet in us-east-1a
resource "aws_subnet" "private-1a" {
  vpc_id = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags{
    Name="Private 1a Subnet"
  }
}
# Another private subnet in us-east-1d
resource "aws_subnet" "private-1d" {
  vpc_id = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1d"
  tags{
    Name="Private 1d Subnet"
  }
}
# Public subnet in 1a
resource "aws_subnet" "public-1a" {
  vpc_id = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags{
    Name="Public 1a Subnet"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "myigw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags {
    Name = "MyVPC Inernet Gateway"
  }
}
# Route Table for the public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myigw.id}"
  }
  tags{
    Name="Public Route Table"
  }
}
# Associate this route table with public subnet
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = "${aws_subnet.public-1a.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

