provider "aws" {
  region  = var.region
  profile = "terraform"
}

resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket                  = aws_s3_bucket.frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "frontend_main" {
  comment = "OAI for frontend main"

  lifecycle {
    ignore_changes = [comment]
  }
}

resource "aws_cloudfront_distribution" "frontend_main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Main frontend"
  price_class         = "PriceClass_200"
  default_root_object = "index.html"

  aliases = var.frontend_aliases

  origin {
    domain_name         = "${var.frontend_bucket_name}.s3.ap-northeast-2.amazonaws.com"
    origin_id           = var.frontend_origin_id
    origin_path         = var.frontend_origin_path
    connection_attempts = 3
    connection_timeout  = 10

    origin_shield {
      enabled              = true
      origin_shield_region = var.origin_shield_region
    }

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = var.frontend_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = var.default_cache_policy_id
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn_frontend
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  lifecycle {
    ignore_changes = [
      origin,
      default_cache_behavior[0].target_origin_id
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "images" {
  comment = "OAI for images"

  lifecycle {
    ignore_changes = [comment]
  }
}

resource "aws_cloudfront_distribution" "images" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Image CDN"
  price_class         = "PriceClass_200"

  aliases = var.image_aliases

  origin {
    domain_name         = "${var.frontend_bucket_name}.s3.ap-northeast-2.amazonaws.com"
    origin_id           = var.image_origin_id
    origin_path         = var.image_origin_path
    connection_attempts = 3
    connection_timeout  = 10

    origin_shield {
      enabled              = true
      origin_shield_region = var.origin_shield_region
    }

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.images.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = var.image_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id = var.default_cache_policy_id
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn_images
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  lifecycle {
    ignore_changes = [
      origin,
      default_cache_behavior[0].target_origin_id
    ]
  }
}
