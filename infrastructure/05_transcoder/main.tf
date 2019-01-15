//
// Transcoder infrastructure: manage the ECS instance, security group and domain registration for the
// transcoding server.
//

// Alibaba Cloud provider (source: https://github.com/terraform-providers/terraform-provider-alicloud)
provider "alicloud" {}

// VPC
data "alicloud_vpcs" "avld_vpcs" {
  name_regex = "avld-vpc"
}

// VSwitch in the first zone
data "alicloud_vswitches" "avld_vswitches" {
  name_regex = "avld-vswitch"
}

// Security group and rule
resource "alicloud_security_group" "avld_transcoder_security_group" {
  name = "avld-transcoder-security-group"
  vpc_id = "${data.alicloud_vpcs.avld_vpcs.vpcs.0.id}"
}
resource "alicloud_security_group_rule" "accept_22_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_transcoder_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_80_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "80/80"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_transcoder_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_rtp_stream_rule" {
  type = "ingress"
  ip_protocol = "udp"
  nic_type = "intranet"
  policy = "accept"

  // This range must be in sync with transcoder/src/main/resources/application.properties
  port_range = "30000/50000"

  priority = 1
  security_group_id = "${alicloud_security_group.avld_transcoder_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}

// Powerful ECS instance type
data "alicloud_instance_types" "avld_transcoder_instance_types" {
  cpu_core_count = 8
  memory_size = 32
  availability_zone = "${data.alicloud_vswitches.avld_vswitches.vswitches.0.zone_id}"
  network_type = "Vpc"
}

// Latest supported Ubuntu image
data "alicloud_images" "ubuntu_images" {
  owners = "system"
  name_regex = "ubuntu_18[a-zA-Z0-9_]+64"
  most_recent = true
}

// ECS instance for transcoding
resource "alicloud_instance" "avld_transcoder_ecs" {
  instance_name = "avld-transcoder-ecs"
  description = "Apsara Video Live Demo (transcoder)."

  host_name = "avld-transcoder-ecs"
  password = "${var.ecs_root_password}"

  image_id = "${data.alicloud_images.ubuntu_images.images.0.id}"
  instance_type = "${data.alicloud_instance_types.avld_transcoder_instance_types.instance_types.0.id}"
  system_disk_category = "cloud_ssd"
  system_disk_size = 20

  internet_max_bandwidth_out = 1

  vswitch_id = "${data.alicloud_vswitches.avld_vswitches.vswitches.0.id}"
  security_groups = [
    "${alicloud_security_group.avld_transcoder_security_group.id}"
  ],

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/nginx-transcoder.conf"
    destination = "/tmp/nginx-transcoder.conf"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/transcoder.service"
    destination = "/tmp/transcoder.service"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "../../transcoder/target/apsara-video-live-demo-transcoder-1.0.0.jar"
    destination = "/tmp/transcoder.jar"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "../../transcoder/src/main/resources/application.properties"
    destination = "/tmp/application.properties"
  }

  provisioner "remote-exec" {
    connection {
      host = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    script = "resources/install_transcoder.sh"
  }
}

// Domain records (also add internal addresses with a "-vpc" suffix)
resource "alicloud_dns_record" "avld_transcoder_record_oversea" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.transcoder_sub_domain_name}"
  routing = "oversea"
  value = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "avld_transcoder_record_default" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.transcoder_sub_domain_name}"
  routing = "default"
  value = "${alicloud_instance.avld_transcoder_ecs.public_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "avld_transcoder_private_record_oversea" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.transcoder_sub_domain_name}-vpc"
  routing = "oversea"
  value = "${alicloud_instance.avld_transcoder_ecs.private_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "avld_transcoder_private_record_default" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.transcoder_sub_domain_name}-vpc"
  routing = "default"
  value = "${alicloud_instance.avld_transcoder_ecs.private_ip}"
  ttl = 600
}