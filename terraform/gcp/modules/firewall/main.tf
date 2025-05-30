# firewall module main.tf

resource "google_compute_firewall" "allow_port" {
  name    = "${var.name}-${var.port}"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = [var.port]
  }

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]

  target_tags = [var.target_tag]
}
