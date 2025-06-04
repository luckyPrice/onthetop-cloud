# cloud_nat module main.tf

resource "google_compute_router_nat" "cloud_nat" {
  name                               = var.name
  router                             = var.router
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  enable_endpoint_independent_mapping = true
  min_ports_per_vm                    = 128
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
