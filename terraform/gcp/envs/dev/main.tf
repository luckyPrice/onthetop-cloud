# dev/main.tf

data "google_compute_network" "vpc" {
  name                = "onthetop-vpc"
}

module "subnet_private" {
  source   = "../../modules/subnet"
  name     = local.private_subnet_name
  region   = var.region
  cidr     = var.private_subnet_cidr
  network  = data.google_compute_network.vpc.id
}

module "subnet_db" {
  source   = "../../modules/subnet"
  name     = local.db_subnet_name
  region   = var.region
  cidr     = var.db_subnet_cidr
  network  = data.google_compute_network.vpc.id
}

module "backend_internal_ip" {
  source     = "../../modules/ip-internal"
  name       = local.backend_ip_name
  region     = var.region
  project_id = var.project_id
  subnetwork = module.subnet_private.self_link
}

module "db_internal_ip" {
  source     = "../../modules/ip-internal"
  name       = local.db_ip_name
  region     = var.region
  project_id = var.project_id
  subnetwork = module.subnet_db.self_link
}

module "backend_instance" {
  source       = "../../modules/compute"
  name         = local.backend_name
  region       = var.region
  machine_type = var.backend_machine_type
  image        = var.backend_image
  subnetwork   = module.subnet_private.self_link
  internal_ip  = module.backend_internal_ip.address
  ssh_keys     = var.ssh_keys
  tags         = [
    for name in ["ssh", "http", "https", "monitoring"] : local.firewall_expanded_rules[name].tag
  ]
}

module "db_instance" {
  source       = "../../modules/compute"
  name         = local.db_name
  region       = var.region
  machine_type = var.db_machine_type
  image        = var.db_image
  subnetwork   = module.subnet_db.self_link
  internal_ip  = module.db_internal_ip.address
  ssh_keys     = var.ssh_keys
  tags         = [
    for name in ["ssh", "mysql", "monitoring"] : local.firewall_expanded_rules[name].tag
  ]
}

module "firewall" {
  for_each    = local.firewall_expanded_rules
  source      = "../../modules/firewall"
  name        = each.value.name
  port        = each.value.port
  source_ranges = each.value.source_ranges
  target_tag  = each.value.tag
  network  = data.google_compute_network.vpc.id
}
