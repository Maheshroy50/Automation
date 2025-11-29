output "public_ip" {
  value = aws_instance.strapi_server.public_ip
}

output "s3_bucket_name" {
  value = aws_s3_bucket.media_bucket.id
}

output "ssh_command" {
  value = "ssh -i strapi-key.pem ubuntu@${aws_instance.strapi_server.public_ip}"
}
