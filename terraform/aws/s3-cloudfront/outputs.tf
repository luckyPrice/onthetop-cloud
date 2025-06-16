output "cloudfront_frontend_domain_name" {
  description = "CloudFront domain for frontend"
  value       = aws_cloudfront_distribution.frontend_main.domain_name
}

output "cloudfront_frontend_hosted_zone_id" {
  description = "Hosted zone ID for frontend CloudFront (used in Route53 alias)"
  value       = aws_cloudfront_distribution.frontend_main.hosted_zone_id
}

output "cloudfront_image_domain_name" {
  description = "CloudFront domain for image CDN"
  value       = aws_cloudfront_distribution.images.domain_name
}

output "cloudfront_image_hosted_zone_id" {
  description = "Hosted zone ID for image CloudFront (used in Route53 alias)"
  value       = aws_cloudfront_distribution.images.hosted_zone_id
}

output "s3_frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.id
}
