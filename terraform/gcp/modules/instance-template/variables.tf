# instance-template module variables.tf

variable "name" { type = string }
variable "machine_type" { type = string }
variable "image" { type = string }
variable "subnetwork" { type = string }
variable "startup_script_path" { type = string }
variable "tags" { type = list(string) }
