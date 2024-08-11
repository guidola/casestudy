# Outputs

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_a_id" {
  description = "ID of the public subnet in AZ A"
  value       = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  description = "ID of the public subnet in AZ B"
  value       = aws_subnet.public_subnet_b.id
}

output "private_data_subnet_a_id" {
  description = "ID of the private subnet in AZ A"
  value       = aws_subnet.private_data_subnet_a.id
}

output "private_data_subnet_b_id" {
  description = "ID of the private subnet in AZ B"
  value       = aws_subnet.private_data_subnet_b.id
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.id
}

output "rds_instance_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.rds_instance.endpoint
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.ecr_repo.repository_url
}
