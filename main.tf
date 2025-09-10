terraform {

  required_version = ">= 1.5.0"

  required_providers {

    aws = {

      source  = "hashicorp/aws"

      version = "~> 5.0"

    }

  }

}
 
provider "aws" {

  region = var.region

}
 
# EKS cluster with one managed node group (2 nodes)

module "eks" {

  source  = "terraform-aws-modules/eks/aws"

  version = "~> 20.0"
 
  cluster_name    = var.cluster_name

  cluster_version = "1.29"
 
  vpc_id     = var.vpc_id

  subnet_ids = var.private_subnet_ids
 
  enable_irsa = true
 
  eks_managed_node_groups = {

    default2 = {

      min_size     = 2

      max_size     = 3

      desired_size = 2
 
      instance_types = ["t3.medium"]

      capacity_type  = "ON_DEMAND"

    }

  }

}
 
# To let kubectl know where the cluster is

data "aws_eks_cluster" "this" {

  name = module.eks.cluster_name

  depends_on = [module.eks]

}

data "aws_eks_cluster_auth" "this" {

  name = module.eks.cluster_name

}
 
output "cluster_name"           { value = module.eks.cluster_name }

output "cluster_endpoint"       { value = data.aws_eks_cluster.this.endpoint }

output "cluster_certificate"    { value = data.aws_eks_cluster.this.certificate_authority[0].data }

output "nodegroup_role_arn"     { value = module.eks.eks_managed_node_groups["default2"].iam_role_arn }
 
# Access entry for clahaan-user6

resource "aws_eks_access_entry" "clahaan_user5" {

  cluster_name  = module.eks.cluster_name   # directly put your cluster name

  principal_arn = "arn:aws:iam::909688465000:user/clahaan-user5"

  type          = "STANDARD"

}

# Attach Cluster Admin policy

resource "aws_eks_access_policy_association" "clahaan_user5_cluster_admin" {

  cluster_name  = module.eks.cluster_name   # directly put your cluster name

  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  principal_arn = aws_eks_access_entry.clahaan_user5.principal_arn

  access_scope {

    type = "cluster"

  }

}