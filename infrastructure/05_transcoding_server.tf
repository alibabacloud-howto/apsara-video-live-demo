// Powerful ECS instance type
data "alicloud_instance_types" "transcoding_instance_types" {
  cpu_core_count = 8
  memory_size = 32
  availability_zone = "${alicloud_vswitch.app_vswitch.availability_zone}"
  network_type = "Vpc"
}

// Latest supported Ubuntu image
data "alicloud_images" "ubuntu_images" {
  owners = "system"
  name_regex = "ubuntu_16[a-zA-Z0-9_]+64"
  most_recent = true
}

// ECS instance for transcoding
resource "alicloud_instance" "transcoding_ecs" {
  instance_name = "livevideo-transcoding-ecs"
  description = "Apsara Video Live Demo (transcoding server)."

  host_name = "livevideo-transcoding-ecs"
  password = "${var.ecs_root_password}"

  image_id = "${data.alicloud_images.ubuntu_images.images.0.id}"
  instance_type = "${data.alicloud_instance_types.transcoding_instance_types.instance_types.0.id}"
  system_disk_category = "cloud_ssd"
  system_disk_size = 20

  internet_max_bandwidth_out = 1

  vswitch_id = "${alicloud_vswitch.app_vswitch.id}"
  security_groups = [
    "${alicloud_security_group.app_security_group.id}"
  ]
}

// Domain record
resource "alicloud_dns_record" "transcoding_record_oversea" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.transcoding_sub_domain_name}"
  routing = "oversea"
  value = "${alicloud_instance.transcoding_ecs.public_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "transcoding_record_default" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.transcoding_sub_domain_name}"
  routing = "default"
  value = "${alicloud_instance.transcoding_ecs.public_ip}"
  ttl = 600
}