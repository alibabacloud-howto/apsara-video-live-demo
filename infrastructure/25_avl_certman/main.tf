//
// Certificate manager infrastructure: manage the ECS instance, security group and domain registration for the
// "Apsara Video Live" pull-domain certificate manager.
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
resource "alicloud_security_group" "avld_certman_security_group" {
  name = "avld-certman-security-group"
  vpc_id = "${data.alicloud_vpcs.avld_vpcs.vpcs.0.id}"
}
resource "alicloud_security_group_rule" "accept_22_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_certman_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_80_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "80/80"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_certman_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}

// ECS instance type
data "alicloud_instance_types" "avld_certman_instance_types" {
  cpu_core_count = 1
  memory_size = 0.5
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
resource "alicloud_instance" "avld_certman_ecs" {
  instance_name = "avld-certman-ecs"
  description = "Apsara Video Live Demo (certificate manager)."

  host_name = "avld-certman-ecs"
  password = "${var.ecs_root_password}"

  image_id = "${data.alicloud_images.ubuntu_images.images.0.id}"
  instance_type = "${data.alicloud_instance_types.avld_certman_instance_types.instance_types.0.id}"
  system_disk_category = "cloud_ssd"
  system_disk_size = 20

  internet_max_bandwidth_out = 1

  vswitch_id = "${data.alicloud_vswitches.avld_vswitches.vswitches.0.id}"
  security_groups = [
    "${alicloud_security_group.avld_certman_security_group.id}"
  ],

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_certman_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/certificate-updater.py"
    destination = "/tmp/certificate-updater.py"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_certman_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/certificate-updater-config.ini"
    destination = "/tmp/certificate-updater-config.ini"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_certman_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/certificate-updater.service"
    destination = "/tmp/certificate-updater.service"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_certman_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/certificate-updater-cron"
    destination = "/tmp/certificate-updater-cron"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_certman_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/install_certman.sh"
    destination = "/tmp/install_certman.sh"
  }

  provisioner "remote-exec" {
    connection {
      host = "${alicloud_instance.avld_certman_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    inline = [
      "chmod +x /tmp/install_certman.sh",
      <<EOF
      /tmp/install_certman.sh \
        ${alicloud_instance.avld_certman_ecs.public_ip} \
        ${var.api_user_accesskey_id} \
        ${var.api_user_accesskey_secret} \
        ${var.api_region_id} \
        ${var.apsaravideolive_pull_top_domain_name} \
        ${var.apsaravideolive_pull_sub_domain_name} \
        ${var.lets_encrypt_email_address}
      EOF
    ]
  }
}

// Domain records
resource "alicloud_dns_record" "avld_certman_record_oversea" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.certman_sub_domain_name}"
  routing = "oversea"
  value = "${alicloud_instance.avld_certman_ecs.public_ip}"
  ttl = 600
}
resource "alicloud_dns_record" "avld_certman_record_default" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.certman_sub_domain_name}"
  routing = "default"
  value = "${alicloud_instance.avld_certman_ecs.public_ip}"
  ttl = 600
}