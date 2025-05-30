locals {
  prefix              = "onthetop"
  vpc_name            = "${local.prefix}-vpc-${var.env}"
  backend_subnet_name = "${local.prefix}-subnet-${var.env}-backend"
  db_subnet_name      = "${local.prefix}-subnet-${var.env}-db"
  backend_ip_name     = "${local.prefix}-ip-${var.env}-backend"
  db_ip_name          = "${local.prefix}-ip-${var.env}-db"
  backend_name        = "${local.prefix}-compute-${var.env}-backend"
  db_name             = "${local.prefix}-compute-${var.env}-db"

  firewall_prefix     = "${local.prefix}-firewall-${var.env}"
  firewall_tag_prefix     = "${local.prefix}-${var.env}"

  env_prefix = "${local.prefix}-${var.env}"

  raw_firewall_ports = [
    { port = ["22"],                   name = "ssh",                 source_ranges = ["0.0.0.0/0"] },
    { port = ["80"],                   name = "http",                source_ranges = ["10.0.0.0/8"] },
    { port = ["443"],                  name = "https",               source_ranges = ["10.0.0.0/8"] },
    { port = ["3306", "9104"],         name = "mysql",               source_ranges = ["10.0.0.0/8"] },
    { port = ["9080", "9100", "9400"], name = "monitoring-targets", source_ranges = ["10.0.0.0/8"] },
  ]

  firewall_tag_map = {
    for rule in local.raw_firewall_ports :
    rule.name => "${local.env_prefix}-${rule.name}"
  }

  firewall_ports = [
    for rule in local.raw_firewall_ports : {
      name          = rule.name
      port          = rule.port
      source_ranges = rule.source_ranges
      tag           = local.firewall_tag_map[rule.name]
    }
  ]
}

module "vpc" {
  source              = "../../modules/vpc"
  name                = local.vpc_name
  region              = var.region
}

module "subnet_backend" {
  source   = "../../modules/subnet"
  name     = local.backend_subnet_name
  region   = var.region
  cidr     = var.backend_subnet_cidr
  network  = module.vpc.vpc_id
}

module "subnet_db" {
  source   = "../../modules/subnet"
  name     = local.db_subnet_name
  region   = var.region
  cidr     = var.db_subnet_cidr
  network  = module.vpc.vpc_id
}

module "backend_internal_ip" {
  source     = "../../modules/ip-internal"
  name       = local.backend_ip_name
  region     = var.region
  project_id = var.project_id
  subnetwork = module.subnet_backend.self_link
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
  zone         = var.zone
  machine_type = var.backend_machine_type
  image        = var.backend_image
  subnetwork   = module.subnet_backend.self_link
  internal_ip  = module.backend_internal_ip.address
  ssh_keys     = var.ssh_keys
  tags         = [
    local.firewall_tag_map["ssh"],
    local.firewall_tag_map["http"],
    local.firewall_tag_map["https"],
    local.firewall_tag_map["monitoring-targets"]
  ]
}

module "db_instance" {
  source       = "../../modules/compute"
  name         = local.db_name
  region       = var.region
  zone         = var.zone
  machine_type = var.db_machine_type
  image        = var.db_image
  subnetwork   = module.subnet_db.self_link
  internal_ip  = module.db_internal_ip.address
  ssh_keys     = var.ssh_keys
  tags         = [
    local.firewall_tag_map["ssh"],
    local.firewall_tag_map["mysql"],
    local.firewall_tag_map["monitoring-targets"]
  ]
}

# 반복적으로 firewall 생성
resource "google_compute_firewall" "rules" {
  for_each = {
    for rule in local.firewall_ports :
    rule.name => rule
  }

  name    = "${local.firewall_tag_prefix}-${each.key}"
  network = module.vpc.vpc_id

  allow {
    protocol = "tcp"
    ports    = each.value.port
  }

  direction     = "INGRESS"
  source_ranges = each.value.source_ranges
  target_tags   = [each.value.tag]
}
