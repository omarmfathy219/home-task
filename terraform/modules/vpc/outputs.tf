output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.main.arn
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_arns" {
  description = "Private subnet ARNs"
  value       = aws_subnet.private[*].arn
}

output "public_subnet_arns" {
  description = "Public subnet ARNs"
  value       = aws_subnet.public[*].arn
}

output "private_subnets_cidr_blocks" {
  description = "Private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnets_cidr_blocks" {
  description = "Public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "availability_zones" {
  description = "Availability zones used"
  value       = aws_subnet.private[*].availability_zone
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_public_ips" {
  description = "NAT Gateway public IPs"
  value       = aws_eip.nat[*].public_ip
}

output "default_security_group_id" {
  description = "Default security group ID"
  value       = aws_security_group.default.id
}

output "default_security_group_arn" {
  description = "Default security group ARN"
  value       = aws_security_group.default.arn
}

output "vpn_gateway_id" {
  description = "VPN Gateway ID"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "route_table_ids" {
  description = "Route table IDs"
  value = {
    public  = aws_route_table.public.id
    private = aws_route_table.private[*].id
  }
}