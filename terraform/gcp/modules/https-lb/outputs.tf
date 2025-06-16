# lb module outputs.tf

output "ip_address" {
  description = "로드밸런서 외부 IP 주소"
  value       = google_compute_global_address.lb_ip.address
}

output "backend_service" {
  description = "Backend 서비스의 self_link"
  value       = google_compute_backend_service.default.self_link
}
