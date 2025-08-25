variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops-task"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.32"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the region"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging stack"
  type        = bool
  default     = true
}

variable "node_groups" {
  description = "EKS node groups configuration"
  type = map(object({
    desired_size = number
    min_size     = number
    max_size     = number
    instance_types = list(string)
    capacity_type  = string
    labels         = map(string)
    taints         = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 5
      instance_types = ["t3.medium", "t3.large"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "dev"
        Project     = "devops-task"
        NodeGroup   = "general"
      }
      taints = []
    }
    monitoring = {
      desired_size = 2
      min_size     = 1
      max_size     = 3
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "dev"
        Project     = "devops-task"
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
    }
  }
}
