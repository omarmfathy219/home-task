variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS cluster endpoint"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where the EKS cluster will be deployed"
  type        = list(string)
}

variable "cluster_security_group_additional_rules" {
  description = "Additional security group rules for the EKS cluster"
  type        = any
  default     = {}
}

variable "node_security_group_additional_rules" {
  description = "Additional security group rules for the EKS nodes"
  type        = any
  default     = {}
}

variable "eks_managed_node_groups" {
  description = "EKS managed node groups configuration"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_cluster_autoscaler" {
  description = "Enable cluster autoscaler"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Enable metrics server"
  type        = bool
  default     = true
}

variable "cluster_autoscaler_settings" {
  description = "Cluster autoscaler configuration"
  type = object({
    scale_down_enabled        = bool
    scan_interval            = string
    scale_down_delay_after_add = string
  })
  default = {
    scale_down_enabled        = true
    scan_interval            = "30s"
    scale_down_delay_after_add = "10m"
  }
}
