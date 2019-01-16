//
// TURN / STUN server infrastructure: manage the ECS instance, security group and domain registration for Coturn.
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

// Security group and rules
resource "alicloud_security_group" "avld_turnstun_security_group" {
  name = "avld-turnstun-security-group"
  vpc_id = "${data.alicloud_vpcs.avld_vpcs.vpcs.0.id}"
}
resource "alicloud_security_group_rule" "accept_22_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_turnstun_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_3478-9_udp_rule" {
  type = "ingress"
  ip_protocol = "udp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "3478/3479"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_turnstun_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_3478-9_tcp_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "3478/3479"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_turnstun_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_5349-50_udp_rule" {
  type = "ingress"
  ip_protocol = "udp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "5349/5350"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_turnstun_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_5349-50_tcp_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "5349/5350"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_turnstun_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_udp_relay_rule" {
  type = "ingress"
  ip_protocol = "udp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "49152/65535"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_turnstun_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}

// ECS instance type
data "alicloud_instance_types" "avld_turnstun_instance_types" {
  cpu_core_count = 1
  memory_size = 2
  availability_zone = "${data.alicloud_vswitches.avld_vswitches.vswitches.0.zone_id}"
  network_type = "Vpc"
}

// Latest supported Ubuntu image
data "alicloud_images" "ubuntu_images" {
  owners = "system"
  name_regex = "ubuntu_18[a-zA-Z0-9_]+64"
  most_recent = true
}

// ECS instance
resource "alicloud_instance" "avld_turnstun_instance_ecs" {
  instance_name = "avld-turnstun-ecs"
  description = "Apsara Video Live Demo (TURN / STUN server)."

  host_name = "avld-turnstun-ecs"
  password = "${var.ecs_root_password}"

  image_id = "${data.alicloud_images.ubuntu_images.images.0.id}"
  instance_type = "${data.alicloud_instance_types.avld_turnstun_instance_types.instance_types.0.id}"
  system_disk_category = "cloud_ssd"
  system_disk_size = 20

  internet_max_bandwidth_out = 1

  vswitch_id = "${data.alicloud_vswitches.avld_vswitches.vswitches.0.id}"
  security_groups = [
    "${alicloud_security_group.avld_turnstun_security_group.id}"
  ]

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_turnstun_instance_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/install_turnstun_server.sh"
    destination = "/tmp/install_turnstun_server.sh"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_turnstun_instance_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/coturn.service"
    destination = "/tmp/coturn.service"
  }

  provisioner "remote-exec" {
    connection {
      host = "${alicloud_instance.avld_turnstun_instance_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    inline = [
      "chmod +x /tmp/install_turnstun_server.sh",
      "/tmp/install_turnstun_server.sh ${var.turnstun_sub_domain_name}.${var.domain_name} ${alicloud_instance.avld_turnstun_instance_ecs.public_ip} ${var.turn_user} ${var.turn_password}"
    ]
  }
}

// Domain records (also add internal addresses with a "-vpc" suffix)
resource "alicloud_dns_record" "avld_turnstun_record_oversea" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.turnstun_sub_domain_name}"
  routing = "oversea"
  value = "${alicloud_instance.avld_turnstun_instance_ecs.public_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "avld_turnstun_record_default" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.turnstun_sub_domain_name}"
  routing = "default"
  value = "${alicloud_instance.avld_turnstun_instance_ecs.public_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "avld_turnstun_private_record_oversea" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.turnstun_sub_domain_name}-vpc"
  routing = "oversea"
  value = "${alicloud_instance.avld_turnstun_instance_ecs.private_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "avld_turnstun_private_record_default" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.turnstun_sub_domain_name}-vpc"
  routing = "default"
  value = "${alicloud_instance.avld_turnstun_instance_ecs.private_ip}"
  ttl = 600
}
