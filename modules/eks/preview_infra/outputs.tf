output "preview_host" {
  value = aws_route53_record.preview.fqdn
}

output "service_urls" {
  value = [for service in local.services : "https://${aws_route53_record.preview.fqdn}/api/${service.name}/"]
}
