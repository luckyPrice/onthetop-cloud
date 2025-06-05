# health-check module main.tf

resource "google_compute_health_check" "this" {
  name               = var.name
  project            = var.project_id
  check_interval_sec = var.check_interval_sec
  timeout_sec        = var.timeout_sec
  healthy_threshold  = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  dynamic "http_health_check" {
    for_each = var.protocol == "HTTP" ? [1] : []
    content {
      port         = var.port
      request_path = var.request_path
    }
  }

  dynamic "https_health_check" {
    for_each = var.protocol == "HTTPS" ? [1] : []
    content {
      port         = var.port
      request_path = var.request_path
    }
  }

  dynamic "tcp_health_check" {
    for_each = var.protocol == "TCP" ? [1] : []
    content {
      port = var.port
    }
  }
}
