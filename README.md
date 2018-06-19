# HashiCorp Terraform playground

## Using root module outputs

```bash
terraform get -update   # Create symlink from the module to the .terraform folder
terraform init          # Download aws provider v1.23.0 or higher
terraform plan          # Dry run
terraform apply         # Full run
terraform output        # See the output
```

## Using maps

```
terraform plan

Terraform will perform the following actions:

  + aws_subnet.public
      id:                                    <computed>
      assign_ipv6_address_on_creation:       "false"
      availability_zone:                     <computed>
      cidr_block:                            "10.0.1.0/24"
      ipv6_cidr_block:                       <computed>
      ipv6_cidr_block_association_id:        <computed>
      map_public_ip_on_launch:               "false"
      vpc_id:                                "${aws_vpc.my_vpc.id}"

  + aws_vpc.my_vpc
      id:                                    <computed>
      assign_generated_ipv6_cidr_block:      "false"
      cidr_block:                            "10.0.0.0/16"
      default_network_acl_id:                <computed>
      default_route_table_id:                <computed>
      default_security_group_id:             <computed>
      dhcp_options_id:                       <computed>
      enable_classiclink:                    <computed>
      enable_classiclink_dns_support:        <computed>
      enable_dns_hostnames:                  <computed>
      enable_dns_support:                    "true"
      instance_tenancy:                      <computed>
      ipv6_association_id:                   <computed>
      ipv6_cidr_block:                       <computed>
      main_route_table_id:                   <computed>

  + module.mighty_trousers.aws_instance.app-server
      id:                                    <computed>
      ami:                                   "ami-9bf712f4"
      associate_public_ip_address:           <computed>
      availability_zone:                     <computed>
      ebs_block_device.#:                    <computed>
      ephemeral_block_device.#:              <computed>
      get_password_data:                     "false"
      instance_state:                        <computed>
      instance_type:                         "t2.large"
      ipv6_address_count:                    <computed>
      ipv6_addresses.#:                      <computed>
      key_name:                              <computed>
      network_interface.#:                   <computed>
      network_interface_id:                  <computed>
      password_data:                         <computed>
      placement_group:                       <computed>
      primary_network_interface_id:          <computed>
      private_dns:                           <computed>
      private_ip:                            <computed>
      public_dns:                            <computed>
      public_ip:                             <computed>
      root_block_device.#:                   <computed>
      security_groups.#:                     <computed>
      source_dest_check:                     "true"
      subnet_id:                             "${var.subnet_id}"
      tags.%:                                "1"
      tags.Name:                             "MightyTrousers"
      tenancy:                               <computed>
      volume_tags.%:                         <computed>
      vpc_security_group_ids.#:              <computed>

  + module.mighty_trousers.aws_security_group.allow_http
      id:                                    <computed>
      arn:                                   <computed>
      description:                           "Allow HTTP traffic"
      egress.#:                              "1"
      egress.482069346.cidr_blocks.#:        "1"
      egress.482069346.cidr_blocks.0:        "0.0.0.0/0"
      egress.482069346.description:          ""
      egress.482069346.from_port:            "0"
      egress.482069346.ipv6_cidr_blocks.#:   "0"
      egress.482069346.prefix_list_ids.#:    "0"
      egress.482069346.protocol:             "-1"
      egress.482069346.security_groups.#:    "0"
      egress.482069346.self:                 "false"
      egress.482069346.to_port:              "0"
      ingress.#:                             "1"
      ingress.2214680975.cidr_blocks.#:      "1"
      ingress.2214680975.cidr_blocks.0:      "0.0.0.0/0"
      ingress.2214680975.description:        ""
      ingress.2214680975.from_port:          "80"
      ingress.2214680975.ipv6_cidr_blocks.#: "0"
      ingress.2214680975.protocol:           "tcp"
      ingress.2214680975.security_groups.#:  "0"
      ingress.2214680975.self:               "false"
      ingress.2214680975.to_port:            "80"
      name:                                  "MightyTrousers allow_http"
      owner_id:                              <computed>
      revoke_rules_on_delete:                "false"
      vpc_id:                                "${var.vpc_id}"
```

Note: It creates t2.large instance (`./variables.tf` = *dev* versus `./modules/application/variables.tf` = *prod*).

## Using lists

`aws_security_group_allow_http.*.id` is essentially the same as:

`aws_security_group_allow_http.0.id`
`aws_security_group_allow_http.1.id`
`...`
`aws_security_group_allow_http.N.id`

To play with different interpolation functions interactively, use:

```bash
terraform console
```

## Supplying variables inline

```bash
terraform plan -var 'environment=dev' -var 'key1=value' -var 'key2=value' ...
```

Note: It creates t2.micro instance.

```bash
terraform plan -var 'allow_ssh_access=["52.123.123.123/32"]'
```

```bash
terraform plan -var 'subnet_cidrs={public="172.0.16.0/24", private="172.0.17.0/24"}'
```

## Environment variables

* Automatically reads all ENV with `TF_VAR_*` prefix, e.g. `TF_VAR_region=ap-southeast-2 terraform plan`

* Source the vars file, e.g. `source vars.txt; terraform plan`

## Variable files

```bash
terraform plan -var-file=./development.tfvars
```

# Data sources

It is often the case that some resources already exist and you don't have much control over them. You can still use them inside your Terraform teplates referenced with the `data` keyword.

For example VPC peering between VPC created manually and VPC created in Terraform:

```
data "aws_vpc" "management_layer" {
    id = "xxx-xxxxxxxx"
}

resource "aws_vpc_peering_connection" "my_vpc-management" {
    peer_vpc_id = "${data.aws_vpc.management_layer.id}
    vpc_id      = "${aws_vpc.my_vpc.id}"
    auto_accept = true
}
```

* template_file

```

```

* external_file

Key pair:

```
resource "aws_key_pair" "terraform" {
    key_name   = "terraform"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}
```

IAM policy:

```
resource "aws_iam_role_policy" "s3-assets-all" {
    name   = "s3=assets@all"
    role   = "${aws_iam_role.app-production.id}"
    policy = "${file("policies/s3=assets@all.json")}" # Tip! Naming scheme i am using is ${SERVICE}=${RESOURCE}@${ACTION}
}
```
