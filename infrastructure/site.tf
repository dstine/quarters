// TODO: site content
// TODO: web traffic logging
// TODO: TLS

resource "aws_s3_bucket" "root" {
  bucket = "${var.root_domain}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }

  tags {
    terraform = "true"
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":
    [
      {
	"Sid": "PublicReadGetObject",
        "Effect": "Allow",
	  "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.root_domain}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.root_domain}"
  acl    = "public-read"

  website {
    redirect_all_requests_to = "${var.root_domain}"
  }

  tags {
    terraform = "true"
  }
}

resource "aws_route53_delegation_set" "main" {}

resource "aws_route53_zone" "main" {
  name              = "${var.root_domain}"
  delegation_set_id = "${aws_route53_delegation_set.main.id}"

  tags {
    terraform = "true"
  }
}

resource "aws_route53_record" "root" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "${aws_s3_bucket.root.bucket}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.root.website_domain}"
    zone_id                = "${aws_s3_bucket.root.hosted_zone_id}"
    evaluate_target_health = "true"
  }
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "${aws_s3_bucket.www.bucket}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.www.website_domain}"
    zone_id                = "${aws_s3_bucket.www.hosted_zone_id}"
    evaluate_target_health = "true"
  }
}
