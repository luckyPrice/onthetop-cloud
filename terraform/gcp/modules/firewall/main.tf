# firewall module main.tf

resource "google_compute_firewall" "allow_port" {
  name    = var.name
  network = var.network

  dynamic "allow" {
    for_each = var.protocols
    content {
      protocol = allow.value
      ports    = var.port
    }
  }

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = var.source_ranges
  target_tags   = [var.target_tag]
}
