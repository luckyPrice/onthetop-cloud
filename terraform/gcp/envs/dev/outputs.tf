output "backend_internal_ip" {
  value = module.backend_internal_ip.address
}

output "db_internal_ip" {
  value = module.db_internal_ip.address
}

output "backend_instance_name" {
  value = module.backend_instance.name
}

output "db_instance_name" {
  value = module.db_instance.name
}
