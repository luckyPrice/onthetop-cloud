# router module outputs.tf

output "router_name" {
  description = "Name of the created Cloud Router"
  value       = google_compute_router.this.name
}
