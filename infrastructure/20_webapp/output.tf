output "avld_webapp_ecs_public_ip" {
  value = "${alicloud_instance.avld_webapp_ecs.public_ip}"
}

output "avld_webapp_ecs_domain_name" {
  value = "${alicloud_dns_record.avld_webapp_record_oversea.host_record}.${alicloud_dns_record.avld_webapp_record_oversea.name}"
}