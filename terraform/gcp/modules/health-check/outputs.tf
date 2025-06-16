# health-check module outputs.tf

output "self_link" {
  value = google_compute_health_check.this.self_link
}

output "name" {
  value = google_compute_health_check.this.name
}
