# ./variables.tf

#--------------------------
# Provider
variable "profile" {}
variable "region" {}

#--------------------------
# VPC
variable "aws_region" {}

variable "vpc_name" {}

variable "vpc_cidr" {}

variable "availability_zones" {}

variable "public_subnets" {}

#--------------------------
# AutoScaling Group
variable "ec2_instance_name" {}

variable "ec2_instance_type" {}

variable "ec2_ami" {}

variable "ec2_key_pair" {}
