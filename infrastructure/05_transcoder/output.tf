output "avld_transcoder_ecs_public_ip" {
  value = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
}

output "avld_transcoder_ecs_domain_name" {
  value = "${alicloud_dns_record.avld_transcoder_record_oversea.host_record}.${alicloud_dns_record.avld_transcoder_record_oversea.name}"
}