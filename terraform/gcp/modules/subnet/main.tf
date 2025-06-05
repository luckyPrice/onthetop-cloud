# subnet module main.tf

resource "google_compute_subnetwork" "subnet" {
  name          = var.name
  ip_cidr_range = var.cidr
  region        = var.region
  network       = var.network
  purpose       = "PRIVATE" # 기본값: "PRIVATE" (내부용)
}
