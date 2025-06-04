output "db_primary_internal_ip" {
  value = module.db_primary_internal_ip.address
}

output "db_secondary_internal_ip" {
  value = module.db_secondary_internal_ip.address
}

output "db_primary_instance_name" {
  value = module.db_primary_instance.name
}

output "db_secondary_instance_name" {
  value = module.db_secondary_instance.name
}
