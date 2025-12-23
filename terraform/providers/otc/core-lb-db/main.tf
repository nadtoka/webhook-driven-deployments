locals {
  flavors = {
    core = length(var.flavor_id_core) > 0 ? var.flavor_id_core : var.default_flavor_id
    db   = length(var.flavor_id_db) > 0 ? var.flavor_id_db : var.default_flavor_id
    lb   = length(var.flavor_id_lb) > 0 ? var.flavor_id_lb : var.default_flavor_id
  }

  keypair_public_key = var.use_keypair_workaround && length(var.existing_public_key) > 0 ? var.existing_public_key : tls_private_key.ssh[0].public_key_openssh
  keypair_private_key = var.use_keypair_workaround && length(var.existing_public_key) > 0 ? null : tls_private_key.ssh[0].private_key_pem
  keypair_name_effective = var.use_keypair_workaround && length(var.existing_keypair_name) > 0 ? var.existing_keypair_name : opentelekomcloud_compute_keypair_v2.this[0].name
}

resource "tls_private_key" "ssh" {
  count     = var.use_keypair_workaround && length(var.existing_public_key) > 0 ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "opentelekomcloud_compute_keypair_v2" "this" {
  count      = var.use_keypair_workaround && length(var.existing_keypair_name) > 0 ? 0 : 1
  name       = length(var.keypair_name) > 0 ? var.keypair_name : "${local.base_name}-key"
  public_key = local.keypair_public_key
}

resource "opentelekomcloud_compute_instance_v2" "core" {
  name              = "${local.base_name}-core"
  availability_zone = var.availability_zone
  image_id          = var.image_id
  flavor_id         = local.flavors.core
  key_pair          = local.keypair_name_effective
  security_groups   = [opentelekomcloud_networking_secgroup_v2.ssh.name]
  metadata          = var.instance_tags

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.main.network_id
  }

  user_data = file("${path.module}/cloud-init/cloud-init-core.yaml")

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "opentelekomcloud_compute_instance_v2" "db" {
  name              = "${local.base_name}-db"
  availability_zone = var.availability_zone
  image_id          = var.image_id
  flavor_id         = local.flavors.db
  key_pair          = local.keypair_name_effective
  security_groups   = [opentelekomcloud_networking_secgroup_v2.ssh.name]
  metadata          = var.instance_tags

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.main.network_id
  }

  user_data = file("${path.module}/cloud-init/cloud-init-db.yaml")

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "opentelekomcloud_compute_instance_v2" "lb" {
  name              = "${local.base_name}-lb"
  availability_zone = var.availability_zone
  image_id          = var.image_id
  flavor_id         = local.flavors.lb
  key_pair          = local.keypair_name_effective
  security_groups   = [opentelekomcloud_networking_secgroup_v2.ssh.name]
  metadata          = var.instance_tags

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.main.network_id
  }

  user_data = file("${path.module}/cloud-init/cloud-init-lb.yaml")

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "opentelekomcloud_networking_floatingip_v2" "core" {
  count = var.enable_floating_ip ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "opentelekomcloud_networking_floatingip_v2" "db" {
  count = var.enable_floating_ip ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "opentelekomcloud_networking_floatingip_v2" "lb" {
  count = var.enable_floating_ip ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "core" {
  count       = var.enable_floating_ip ? 1 : 0
  floating_ip = opentelekomcloud_networking_floatingip_v2.core[0].address
  instance_id = opentelekomcloud_compute_instance_v2.core.id
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "db" {
  count       = var.enable_floating_ip ? 1 : 0
  floating_ip = opentelekomcloud_networking_floatingip_v2.db[0].address
  instance_id = opentelekomcloud_compute_instance_v2.db.id
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "lb" {
  count       = var.enable_floating_ip ? 1 : 0
  floating_ip = opentelekomcloud_networking_floatingip_v2.lb[0].address
  instance_id = opentelekomcloud_compute_instance_v2.lb.id
}
