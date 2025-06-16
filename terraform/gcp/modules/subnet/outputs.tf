# subnet module outputs.tf

output "self_link" {
  description = "서브넷의 self_link"
  value       = google_compute_subnetwork.subnet.self_link
}

output "name" {
  description = "서브넷의 이름"
  value       = google_compute_subnetwork.subnet.name
}

output "ip_cidr_range" {
  description = "CIDR 블록"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}
