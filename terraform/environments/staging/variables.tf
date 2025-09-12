variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "staging"
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
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the region"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24"]
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
  description = "EKS node groups configuration for development"
  type = map(object({
    desired_size   = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    capacity_type  = string
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    general = {
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "development"
        Project     = "devops-task"
        NodeGroup   = "general"
        Purpose     = "Development"
      }
      taints = []
    }
    monitoring = {
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        Environment = "development"
        Project     = "devops-task"
        NodeGroup   = "monitoring"
        Monitoring  = "true"
        Purpose     = "Development"
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

variable "enable_cost_optimization" {
  description = "Enable cost optimization features"
  type        = bool
  default     = true
}

variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "enable_auto_scaling" {
  description = "Enable cluster auto-scaling"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable backup and disaster recovery"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "enable_encryption" {
  description = "Enable encryption at rest and in transit"
  type        = bool
  default     = true
}

variable "enable_network_policies" {
  description = "Enable network policies for pod isolation"
  type        = bool
  default     = true
}

variable "enable_pod_security_standards" {
  description = "Enable pod security standards"
  type        = bool
  default     = true
}

variable "enable_audit_logging" {
  description = "Enable Kubernetes audit logging"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Enable metrics server for HPA"
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_cert_manager" {
  description = "Enable cert-manager for SSL certificates"
  type        = bool
  default     = true
}

variable "enable_prometheus_stack" {
  description = "Enable Prometheus monitoring stack"
  type        = bool
  default     = true
}

variable "enable_grafana" {
  description = "Enable Grafana dashboards"
  type        = bool
  default     = true
}

variable "enable_alerting" {
  description = "Enable alerting and notifications"
  type        = bool
  default     = false
}

variable "notification_channels" {
  description = "Notification channels for alerts"
  type = list(object({
    name   = string
    type   = string
    config = map(string)
  }))
  default = []
}

variable "resource_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
    Project     = "DevOps Task"
    Environment = "Development"
  }
}