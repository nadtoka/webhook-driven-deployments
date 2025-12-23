locals {
  env_name  = "${var.service}-${var.stage_name}${var.stage}"
  base_name = trim(var.name_prefix) != "" ? var.name_prefix : local.env_name
}

resource "opentelekomcloud_vpc_v1" "main" {
  name = "${local.env_name}-vpc"
  cidr = var.vpc_cidr
}

resource "opentelekomcloud_vpc_subnet_v1" "main" {
  name       = "${local.env_name}-subnet"
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
  vpc_id     = opentelekomcloud_vpc_v1.main.id
}

resource "opentelekomcloud_networking_secgroup_v2" "ssh" {
  name        = "${local.env_name}-ssh"
  description = "Security group for SSH access"
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "ssh_in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.allowed_ssh_cidr
  security_group_id = opentelekomcloud_networking_secgroup_v2.ssh.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = null
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.ssh.id
}
