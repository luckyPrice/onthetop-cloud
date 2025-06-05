# ip-internal module main.tf

resource "google_compute_address" "this" {
  name         = var.name
  address_type = "INTERNAL"
  subnetwork   = var.subnetwork
  region       = var.region
  project      = var.project_id
  purpose      = "GCE_ENDPOINT"
}
