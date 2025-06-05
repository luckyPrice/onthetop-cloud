# router module main.tf

resource "google_compute_router" "this" {
  name    = var.name
  region  = var.region
  network = var.network
}
