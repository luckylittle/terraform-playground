## Root module

# AWS Frankfurt
provider "aws" {
  region                  = "${var.region}"      # From ./variables.tf
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "cloudawsexam"       # My AWS profile name
}

## Resources
# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "${var.vpc_cidr}"
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "${lookup(var.subnet_cidrs, "public")}"
}

# Default SG
resource "aws_security_group" "default" {
  name        = "Default SG"
  description = "Allow SSH access"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ssh_access}"]
  }
}

# Application 1
module "mighty_trousers" {
  source      = "./modules/application"
  vpc_id      = "${aws_vpc.my_vpc.id}"
  subnet_id   = "${aws_subnet.public.id}"
  name        = "MightyTrousers"
  environment = "${var.environment}"
  extra_sgs   = ["${aws_security_group.default.id}"]
}
