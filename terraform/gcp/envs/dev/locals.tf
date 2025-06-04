# === locals.tf ===
locals {
  prefix              = "onthetop"
  env_prefix          = "${local.prefix}-${var.env}"
  private_subnet_name = "${local.prefix}-subnet-${var.env}-private"
  db_subnet_name      = "${local.prefix}-subnet-${var.env}-db"
  backend_ip_name     = "${local.prefix}-iip-${var.env}-backend"
  db_ip_name          = "${local.prefix}-iip-${var.env}-db"
  backend_name        = "${local.prefix}-compute-${var.env}-backend"
  db_name             = "${local.prefix}-compute-${var.env}-db"

  raw_firewall_rules = {
    ssh = {
      name          = "ssh"
      port          = ["22"]
      source_ranges = ["0.0.0.0/0"]
      tag_suffix    = "ssh"
    },
    http = {
      name          = "http"
      port          = ["80"]
      source_ranges = ["10.0.0.0/8"]
      tag_suffix    = "http"
    },
    https = {
      name          = "https"
      port          = ["443"]
      source_ranges = ["10.0.0.0/8"]
      tag_suffix    = "https"
    },
    mysql = {
      name          = "mysql"
      port          = ["3306", "9104"]
      source_ranges = ["10.0.0.0/8"]
      tag_suffix    = "mysql"
    },
    monitoring = {
      name          = "monitoring-targets"
      port          = ["9080", "9100", "9400"]
      source_ranges = ["10.0.0.0/8"]
      tag_suffix    = "monitoring-targets"
    }
  }

  firewall_expanded_rules = {
    for key, rule in local.raw_firewall_rules : key => {
      name          = "${local.env_prefix}-${rule.name}"
      port          = rule.port
      source_ranges = rule.source_ranges
      tag           = "${local.env_prefix}-${rule.tag_suffix}"
    }
  }
}
