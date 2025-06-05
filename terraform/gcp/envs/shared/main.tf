# shared/main.tf

module "vpc" {
  source              = "../../modules/vpc"
  name                = local.vpc_name
  region              = var.region
}

module "subnet_public" {
  source  = "../../modules/subnet"
  name    = local.public_subnet_name
  region  = var.region
  cidr    = var.public_subnet_cidr
  network = module.vpc.vpc_id
}

module "shared_external_ip" {
  source     = "../../modules/ip-external"
  name       = local.shared_external_ip_name
  region     = var.region
  project_id = var.project_id
}

module "shared_internal_ip" {
  source     = "../../modules/ip-internal"
  name       = local.shared_internal_ip_name
  region     = var.region
  project_id = var.project_id
  subnetwork = module.subnet_public.self_link
}

module "router" {
  source    = "../../modules/router"
  name      = local.router_name
  region    = var.region
  network   = module.vpc.vpc_id
}

module "cloud_nat" {
  source        = "../../modules/cloud_nat"
  name          = local.cloud_nat_name
  region        = var.region
  router        = module.router.router_name
}

module "shared_instance" {
  source       = "../../modules/compute"
  name         = local.shared_name
  region       = var.region
  machine_type = var.shared_machine_type
  image        = var.shared_image
  subnetwork   = module.subnet_public.self_link
  internal_ip  = module.shared_internal_ip.address
  external_ip  = module.shared_external_ip.address
  ssh_keys     = var.ssh_keys
  tags         = [
    for name in ["ssh", "http", "https", "monitoring-server", "vpn"] : local.firewall_expanded_rules[name].tag
  ]
}

module "firewall" {
  for_each    = local.firewall_expanded_rules
  source      = "../../modules/firewall"
  name        = each.value.name
  port        = each.value.port
  source_ranges = each.value.source_ranges
  target_tag  = each.value.tag
  network  = module.vpc.vpc_id
  protocols     = each.value.protocols
}
