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

# Key pair
resource "aws_key_pair" "terraform" {
  key_name   = "terraform"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

# Application 1
module "mighty_trousers" {
  source              = "./modules/application"                           # This can also be e.g. "git::https://gitlab.com/.../module.git?ref=v0.1"
  vpc_id              = "${aws_vpc.my_vpc.id}"
  subnet_id           = "${aws_subnet.public.id}"
  name                = "MightyTrousers"
  environment         = "${var.environment}"
  extra_sgs           = ["${aws_security_group.default.id}"]
  key_pair            = "${aws_key_pair.terraform.key_name}"
  extra_packages      = "${lookup(var.extra_packages, "my_app", "base")}"
  external_nameserver = "${var.external_nameserver}"
  instance_count      = 2
}
