# ip-internal module outputs.tf

output "address" {
  value = google_compute_address.this.address
}

output "self_link" {
  value = google_compute_address.this.self_link
}
