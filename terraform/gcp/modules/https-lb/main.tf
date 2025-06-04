# lb module main.tf

resource "google_compute_global_address" "lb_ip" {
  name = "${var.name}-ip"
}

resource "google_compute_backend_service" "default" {
  name         = "${var.name}-backend"
  protocol     = "HTTP"
  port_name    = var.port_name
  timeout_sec  = 30

  backend {
    group = var.instance_group
  }

  health_checks = [var.health_check]
}

resource "google_compute_url_map" "default" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.default.self_link
}

resource "google_compute_target_https_proxy" "default" {
  name    = "${var.name}-https-proxy"
  url_map = google_compute_url_map.default.self_link
  certificate_map = var.certificate_map
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.name}-forwarding-rule"
  target                = google_compute_target_https_proxy.default.self_link
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
}

