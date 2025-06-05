# firewall module outputs.tf

output "firewall_name" {
  value = google_compute_firewall.allow_port.name
}
