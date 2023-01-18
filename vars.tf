variable "cidr_block" {
  type = string
  description = "VPC CIDR block"
}

variable "name" {
  type = string
  description = "Name of the VPC"
}

variable "additional_tags" {
    type = map
    default = {}
    description = "Additional tags to add"
}

variable "cidr_block_public_subnet" {
    type = list
    description = "A list of CIDR blocks for public subnets that fits inside the VPC CIDR. E.g. 10.1.3.0/24, 10.1.4.0/24, 10.1.5.0/24 if the VPC is 10.1.0.0/16"
}

variable "cidr_block_private_subnet" {
    type = list
    description = "A list of CIDR blocks for public subnets that fits inside the VPC CIDR. E.g. 10.1.3.0/24, 10.1.4.0/24, 10.1.5.0/24 if the VPC is 10.1.0.0/16"
}

variable "cidr_block_data_subnet" {
    type = list
    description = "A list of CIDR blocks for public subnets that fits inside the VPC CIDR. E.g. 10.1.6.0/24, 10.1.7.0/24, 10.1.8.0/24 if the VPC is 10.1.0.0/16"
}
variable "aws_region" { 
    description = "The AWS Region to deploy into (e.g eu-west-1, eu-central-1"
    type = string
}