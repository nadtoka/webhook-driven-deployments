locals {
  env_name  = "${local.service_effective}-${local.stage_name_effective}${local.stage_effective}"
  base_name = trim(local.name_prefix_effective) != "" ? local.name_prefix_effective : local.env_name
}

resource "opentelekomcloud_vpc_v1" "main" {
  name = "${local.env_name}-vpc"
  cidr = coalesce(try(local.vpc_cfg.cidr, null), var.vpc_cidr)
}

resource "opentelekomcloud_vpc_subnet_v1" "main" {
  name       = "${local.env_name}-subnet"
  cidr       = coalesce(try(local.private_subnet.cidr, null), var.subnet_cidr)
  gateway_ip = coalesce(try(local.private_subnet.gateway_ip, null), var.subnet_gateway_ip)
  vpc_id     = opentelekomcloud_vpc_v1.main.id
}

resource "opentelekomcloud_vpc_subnet_v1" "nat" {
  count = local.nat_enabled && length(local.nat_subnet) > 0 ? 1 : 0

  name       = coalesce(try(local.nat_subnet.name, null), "${local.env_name}-nat")
  cidr       = coalesce(try(local.nat_subnet.cidr, null), "10.10.2.0/24")
  gateway_ip = try(local.nat_subnet.gateway_ip, null)
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
  remote_ip_prefix  = try(local.cfg.network.allowed_ssh_cidr, var.allowed_ssh_cidr)
  security_group_id = opentelekomcloud_networking_secgroup_v2.ssh.id
}

resource "opentelekomcloud_networking_secgroup_rule_v2" "all_out" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = null
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.ssh.id
}

resource "opentelekomcloud_vpc_eip_v1" "nat" {
  count = local.nat_enabled ? 1 : 0

  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "${coalesce(try(local.nat_cfg.name, null), local.env_name)}-nat-bw"
    size        = try(local.nat_eip_cfg.bandwidth_mbps, 5)
    share_type  = try(local.nat_eip_cfg.share_type, "PER")
    charge_mode = "traffic"
  }
}

resource "opentelekomcloud_nat_gateway_v2" "main" {
  count = local.nat_enabled ? 1 : 0

  name                = coalesce(try(local.nat_cfg.name, null), "${local.env_name}-nat")
  description         = "NAT gateway for ${local.env_name}"
  internal_network_id = local.nat_enabled && length(opentelekomcloud_vpc_subnet_v1.nat) > 0 ? opentelekomcloud_vpc_subnet_v1.nat[0].id : opentelekomcloud_vpc_subnet_v1.main.id
  router_id           = opentelekomcloud_vpc_v1.main.id
  spec                = tostring(local.nat_spec)
}

resource "opentelekomcloud_nat_snat_rule_v2" "main" {
  count = local.nat_enabled ? 1 : 0

  nat_gateway_id = opentelekomcloud_nat_gateway_v2.main[0].id
  network_id = (
    local.nat_snat_target == "nat" && length(opentelekomcloud_vpc_subnet_v1.nat) > 0 ?
    opentelekomcloud_vpc_subnet_v1.nat[0].network_id :
    opentelekomcloud_vpc_subnet_v1.main.network_id
  )
  floating_ip_id = opentelekomcloud_vpc_eip_v1.nat[0].id
}
