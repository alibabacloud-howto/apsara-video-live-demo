output "avld_webrtcgw_ecs_public_ip" {
  value = "${alicloud_instance.avld_webrtcgw_instance_ecs.public_ip}"
}

output "avld_webrtcgw_ecs_domain_name" {
  value = "${alicloud_dns_record.avld_webrtcgw_record_oversea.host_record}.${alicloud_dns_record.avld_webrtcgw_record_oversea.name}"
}