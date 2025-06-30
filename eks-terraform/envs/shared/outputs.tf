# Shared VPC ID (Shared VPC ID)
output "shared_vpc_id" {
  description = "The ID of the Shared VPC" # Shared VPC의 ID
  value       = data.aws_vpc.existing_shared.id
}
