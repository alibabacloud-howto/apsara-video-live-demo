output "avld_turnstun_ecs_public_ip" {
  value = "${alicloud_instance.avld_turnstun_instance_ecs.public_ip}"
}

output "avld_turnstun_ecs_domain_name" {
  value = "${alicloud_dns_record.avld_turnstun_record_oversea.host_record}.${alicloud_dns_record.avld_turnstun_record_oversea.name}"
}