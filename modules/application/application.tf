# Variables
variable "vpc_id" {}

variable "subnet_id" {}

variable "name" {}

variable "key_pair" {}

# SG
resource "aws_security_group" "allow_http" {
  name        = "${var.name} allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# AMI data source to fetch AMI
data "aws_ami" "app-ami" {
  most_recent = true     # My own most recent AMI
  owners      = ["self"]
}

# EC2
resource "aws_instance" "app-server" {
  ami                    = "${data.aws_ami.app-ami.id}"
  instance_type          = "${lookup(var.instance_type, var.environment)}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${distinct(concat(var.extra_sgs, aws_security_group.allow_http.*.id))}"] # Join multiple lists, without duplicates
  key_name               = "${var.key_pair}"

  tags {
    Name = "${var.name}"
  }
}

output "hostname" {
  value = "${aws_instance.app-server.private_dns}"
}
