output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "cluster_info" {
  description = "Cluster information"
  value = {
    name    = module.eks.cluster_name
    version = module.eks.cluster_version
    region  = var.aws_region
    vpc_id  = module.vpc.vpc_id
    subnets = {
      private = module.vpc.private_subnets
      public  = module.vpc.public_subnets
    }
    environment = var.environment
    project     = var.project_name
  }
}