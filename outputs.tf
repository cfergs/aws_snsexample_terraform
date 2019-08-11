output "s3bucket" {
  value = "${aws_s3_bucket.bucket.id}"
}