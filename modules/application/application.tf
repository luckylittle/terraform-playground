## Resources
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
data "aws_ami" "centos" {
  most_recent = true             # CentOS most recent AMI
  owners      = ["679593333241"]
}

# EC2
resource "aws_instance" "app-server" {
  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${lookup(var.instance_type, var.environment)}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${distinct(concat(var.extra_sgs, aws_security_group.allow_http.*.id))}"] # Join multiple lists, without duplicates
  key_name               = "${var.key_pair}"
  user_data              = "${data.template_file.user_data.rendered}"

  tags {
    Name = "${var.name}"
  }

  lifecycle {
    ignore_changes = ["user_data"] # Changing user_data normally leads to resource recreation
  }

  count = "${var.instance_count}"
}

output "public_ip" {
  value = "${join(",", aws_instance.app-server.*.public_ip)}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars {
    packages   = "${var.extra_packages}"
    nameserver = "${var.external_nameserver}"
  }
}
