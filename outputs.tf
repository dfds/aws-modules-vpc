output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "data_subnet_ids" {
  value = aws_subnet.nated[*].id
}

output "public_subnet_ranges" {
  value = var.cidr_block_public_subnet
}

output "private_subnet_ranges" {
  value = var.cidr_block_private_subnet
}

output "data_subnet_ranges" {
  value = var.cidr_block_data_subnet
}