//
// Webapp infrastructure: manage the ECS instance, security group and domain registration for the
// web application.
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
resource "alicloud_security_group" "avld_webapp_security_group" {
  name = "avld-webapp-security-group"
  vpc_id = "${data.alicloud_vpcs.avld_vpcs.vpcs.0.id}"
}
resource "alicloud_security_group_rule" "accept_22_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "22/22"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_webapp_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_80_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "80/80"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_webapp_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "accept_443_rule" {
  type = "ingress"
  ip_protocol = "tcp"
  nic_type = "intranet"
  policy = "accept"
  port_range = "443/443"
  priority = 1
  security_group_id = "${alicloud_security_group.avld_webapp_security_group.id}"
  cidr_ip = "0.0.0.0/0"
}

// ECS instance type
data "alicloud_instance_types" "avld_webapp_instance_types" {
  cpu_core_count = 2
  memory_size = 4
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
resource "alicloud_instance" "avld_webapp_ecs" {
  instance_name = "avld-webapp-ecs"
  description = "Apsara Video Live Demo (web application)."

  host_name = "avld-webapp-ecs"
  password = "${var.ecs_root_password}"

  image_id = "${data.alicloud_images.ubuntu_images.images.0.id}"
  instance_type = "${data.alicloud_instance_types.avld_webapp_instance_types.instance_types.0.id}"
  system_disk_category = "cloud_ssd"
  system_disk_size = 20

  internet_max_bandwidth_out = 1

  vswitch_id = "${data.alicloud_vswitches.avld_vswitches.vswitches.0.id}"
  security_groups = [
    "${alicloud_security_group.avld_webapp_security_group.id}"
  ],

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_webapp_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/nginx-webapp.conf"
    destination = "/tmp/nginx-webapp.conf"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_webapp_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/webapp.service"
    destination = "/tmp/webapp.service"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_webapp_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "../../webapp/target/apsara-video-live-demo-webapp-1.0.0.jar"
    destination = "/tmp/webapp.jar"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_webapp_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "../../webapp/src/main/resources/application.properties"
    destination = "/tmp/application.properties"
  }

  provisioner "file" {
    connection {
      host = "${alicloud_instance.avld_webapp_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    source = "resources/install_webapp.sh"
    destination = "/tmp/install_webapp.sh"
  }
}

// Domain records (also add internal addresses with a "-vpc" suffix)
resource "alicloud_dns_record" "avld_webapp_record_oversea" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.webapp_sub_domain_name}"
  routing = "oversea"
  value = "${alicloud_instance.avld_webapp_ecs.public_ip}"
  ttl = 600

  provisioner "remote-exec" {
    connection {
      host = "${alicloud_instance.avld_webapp_ecs.public_ip}"
      user = "root"
      password = "${var.ecs_root_password}"
    }
    inline = [
      "chmod +x /tmp/install_webapp.sh",
      <<EOF
      /tmp/install_webapp.sh \
        ${var.turnstun_sub_domain_name}.${var.domain_name} \
        ${var.turn_user} \
        ${var.turn_password} \
        ${var.webrtcgw_sub_domain_name}.${var.domain_name} \
        ${var.transcoder_sub_domain_name}-vpc.${var.domain_name} \
        ${var.apsaravideolive_user_accesskey_id} \
        ${var.apsaravideolive_user_accesskey_secret} \
        ${var.apsaravideolive_region_id} \
        ${var.apsaravideolive_push_domain} \
        ${var.apsaravideolive_pull_domain} \
        ${var.apsaravideolive_app_name} \
        ${var.apsaravideolive_push_auth_primary_key} \
        ${var.apsaravideolive_push_auth_validity_period} \
        ${var.apsaravideolive_pull_auth_primary_key} \
        ${var.apsaravideolive_pull_auth_validity_period} \
        ${var.webapp_sub_domain_name}.${var.domain_name} \
        ${var.lets_encrypt_email_address}
      EOF
    ]
  }
}
resource "alicloud_dns_record" "avld_webapp_record_default" {
  name = "${var.domain_name}"
  type = "A"
  host_record = "${var.webapp_sub_domain_name}"
  routing = "default"
  value = "${alicloud_instance.avld_webapp_ecs.public_ip}"
  ttl = 600
}