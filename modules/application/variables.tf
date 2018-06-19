variable "environment" {
  default = "dev"
}

variable "instance_type" {
  type = "map"

  default = {
    dev  = "t2.micro"
    test = "t2.medium"
    prod = "t2.large"
  }
}

variable "extra_sgs" {
  default = []
}
