variable "region" {
  default = "ap-northeast-2"
}

variable "frontend_bucket_name" {
  default = "onthe-top"
}

variable "frontend_aliases" {
  default = ["onthe-top.com", "www.onthe-top.com"]
}

variable "image_aliases" {
  default = ["img.onthe-top.com"]
}

variable "frontend_origin_id" {
  default = "frontendMainOrigin"
}

variable "image_origin_id" {
  default = "imagesOrigin"
}

variable "frontend_origin_path" {
  default = "/frontend/prod/blue"
}

variable "image_origin_path" {
  default = "/assets/images"
}

variable "origin_shield_region" {
  default = "ap-northeast-2"
}

variable "default_cache_policy_id" {
  default = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "acm_cert_arn_frontend" {
  type = string
}

variable "acm_cert_arn_images" {
  type = string
}
