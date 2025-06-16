# cloud_nat module outputs.tf

output "nat_name" {
  description = "Name of the created NAT"
  value       = google_compute_router_nat.cloud_nat.name
}
