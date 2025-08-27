

provider "aws" {
  region = "us-east-1"

}


#s3 Bucket
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
}

#Enable static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket  = aws_s3_bucket.website.id


 index_document {
  suffix = "index.html"

}
}

# upload index.html

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"

}
#public read policy 

resource "aws_s3_bucket_policy" "public" {
  bucket  = aws_s3_bucket.website.id
  policy  = jsonencode ( {
    Version  = "2012-10-17"
    Statement = [
    { 
     Effect    =  "Allow"
     Principal = "*", 
     Action    = "${aws_s3_bucket.website.arn}/*"
     Resource  = "${aws_s3_bucket.website.arn}/*"
   }
]
})
}

#cloudfront distribution 
resource "aws_cloudfront_distribution" "cdn" {
  origin {
   domain_name  = aws_s3_bucket_website_configuration.website.website_endpoint
   origin_id    = "s3-origin"

  custom_origin_config {
     http_port                = 80 
     https_port               = 443
     origin_protocol_policy   = "http-only"
     origin_ssl_protocols     = ["TLS1.2"]
}
}

enabled              = true
default_root_object  = "index.html"

default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type  = "none"
}
}

viewer_certificate {
 cloudfront_default_certificate = true
}
}

