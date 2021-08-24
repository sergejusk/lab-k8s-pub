variable "region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_cidr_range" {
  type    = string
  default = "11.0.0.0/16"
}

variable "public_subnets" {
  type    = list(string)
  default = ["11.0.0.0/22", "11.0.4.0/22", "11.0.8.0/22"]
}

variable "private_subnets" {
  type = list(string)
  default = ["11.0.12.0/22", "11.0.16.0/22", "11.0.20.0/22"]
}

variable "vpc_name" {
  type    = string
  default = "test-vpc"
}

variable "cluster_name" {
  type    = string
  default = "test-k8s"
}