terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_name             = "${var.project_name}-vpc"
  vpc_cidr            = var.vpc_cidr
  environment         = var.environment
  availability_zones  = var.availability_zones
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  enable_nat_gateway  = true
  single_nat_gateway  = false
  enable_vpn_gateway  = false
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# EKS Cluster Module
module "eks" {
  source = "./modules/eks"
  
  cluster_name                    = "${var.project_name}-cluster"
  cluster_version                = var.kubernetes_version
  cluster_endpoint_public_access = true
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                  = "tcp"
      from_port                 = 1025
      to_port                   = 65535
      type                      = "ingress"
      source_node_security_group = true
    }
  }
  
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  
  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 5
      
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "ON_DEMAND"
      
      labels = {
        Environment = var.environment
        Project     = var.project_name
        NodeGroup   = "general"
      }
      
      taints = []
      
      tags = {
        ExtraTag = "eks-node-group"
      }
    }
    
    monitoring = {
      desired_size = 2
      min_size     = 1
      max_size     = 3
      
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      
      labels = {
        Environment = var.environment
        Project     = var.project_name
        NodeGroup   = "monitoring"
        Monitoring  = "true"
      }
      
      taints = [
        {
          key    = "monitoring"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
      
      tags = {
        ExtraTag = "monitoring-node-group"
      }
    }
  }
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Application Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  
  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }
  
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  
  set {
    name  = "region"
    value = var.aws_region
  }
  
  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }
  
  depends_on = [module.eks]
}

# External DNS for automatic DNS management
resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  
  set {
    name  = "provider"
    value = "aws"
  }
  
  set {
    name  = "policy"
    value = "sync"
  }
  
  set {
    name  = "registry"
    value = "txt"
  }
  
  set {
    name  = "txtOwnerId"
    value = "eks"
  }
    
  set {
    name  = "aws.assumeRoleArn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-external-dns-role"
  }
  
  depends_on = [module.eks]
}

# IAM Role for External DNS
resource "aws_iam_role" "external_dns" {
  name = "${var.project_name}-external-dns-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "external_dns" {
  name = "${var.project_name}-external-dns-policy"
  role = aws_iam_role.external_dns.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}