

output "bucket_name" {
 description = "The name of the s3 bucket"
 value       = var.bucket_name

}

output "s3_website_endpoint" {
 description  = "the endpoint of the s3 static website "
 value        = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "cloudfornt_domain_name" {
 description = "The_CloudFront_distribution domain name"
 value       = aws_cloudfront_distribution.cdn.domain_name

}

