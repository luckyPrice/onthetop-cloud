# ip-external module main.tf

resource "google_compute_address" "this" {
  name    = var.name
  address_type = "EXTERNAL"
  region  = var.region
  project = var.project_id
}
