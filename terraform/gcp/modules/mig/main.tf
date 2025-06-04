# mig module main.tf

resource "google_compute_region_instance_group_manager" "this" {
  name               = var.name
  region             = var.region
  project            = var.project_id
  base_instance_name = var.instance_base_name != null ? var.instance_base_name : var.name

  version {
    instance_template = var.instance_template
    name              = "primary"
  }

  target_size = var.target_size

  named_port {
    name = var.named_port
    port = var.port
  }

  dynamic "auto_healing_policies" {
    for_each = var.health_check != null ? [1] : []
    content {
      health_check      = var.health_check
      initial_delay_sec = var.auto_healing_initial_delay
    }
  }

  update_policy {
    type                   = var.update_policy.type
    minimal_action         = var.update_policy.minimal_action
    replacement_method     = var.update_policy.replacement_method
    max_surge_fixed        = var.update_policy.max_surge_fixed
    max_unavailable_fixed  = var.update_policy.max_unavailable_fixed
  }
}
