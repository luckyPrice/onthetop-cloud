# instance-template module outputs.tf

output "template_self_link" {
  value = google_compute_instance_template.this.self_link
}

output "template_name" {
  value = google_compute_instance_template.this.name
}
