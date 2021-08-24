provider "aws" {
  region  = var.region
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com" # to get external IP and add to EKS access
}

data "aws_availability_zones" "azs" {}

module "vpc" {
  source                    = "terraform-aws-modules/vpc/aws"
  version                   = "3.2.0"

  name                      = var.vpc_name
  cidr                      = var.vpc_cidr_range

  enable_nat_gateway        = true  
  single_nat_gateway        = true # false - to enable for each AV zone Nat
  one_nat_gateway_per_az    = false # true - to enable for each AV zone Nat
  map_public_ip_on_launch   = false 
  enable_dns_hostnames      = true

  azs                       = slice(data.aws_availability_zones.azs.names, 0, 3) # change last digit to make smaller AV zones range. Currently used all 3
  
  public_subnets            = var.public_subnets
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  private_subnets                               = var.private_subnets
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

module "eks" {
  source                                = "terraform-aws-modules/eks/aws"
  version                               = "17.1.0"
  cluster_name                          = var.cluster_name
  cluster_version                       = "1.20"
  subnets                               = module.vpc.private_subnets
  vpc_id                                = module.vpc.vpc_id
  manage_cluster_iam_resources          = true
  manage_aws_auth                       = true
  cluster_endpoint_private_access       = true
  cluster_endpoint_public_access        = true
  cluster_endpoint_public_access_cidrs  = ["${chomp(data.http.myip.body)}/32"]

  workers_group_defaults = {
  	root_volume_type                = "gp2"
    root_volume_size                = 30
  }
  worker_groups = [
    {
      name                          = "group-1-new"
      instance_type                 = "t3.small"
      enable_monitoring             = false
      public_ip                     = false
      asg_desired_capacity          = 2
      asg_max_size                  = 4
      asg_min_size                  = 0

    },
  ]
}