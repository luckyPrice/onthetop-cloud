locals {
  prefix              = "onthetop"
  vpc_name            = "${local.prefix}-vpc-${var.env}"
  backend_subnet_name = "${local.prefix}-subnet-${var.env}-backend"
  db_subnet_name      = "${local.prefix}-subnet-${var.env}-db"
  backend_ip_name     = "${local.prefix}-ip-${var.env}-backend"
  db_ip_name          = "${local.prefix}-ip-${var.env}-db"
  backend_name        = "${local.prefix}-compute-${var.env}-backend"
  db_name             = "${local.prefix}-compute-${var.env}-db"
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
}

# module "firewall" {
#   source  = "../../modules/firewall"
#   network = module.vpc.vpc_id
# }
