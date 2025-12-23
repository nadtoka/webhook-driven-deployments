terraform {
  required_version = ">= 1.3.0"

  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">= 1.35.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }
}

provider "opentelekomcloud" {
  region = local.region_effective
}

locals {
  cfg = yamldecode(file(var.config_path))

  meta = try(local.cfg.meta, {})

  service_effective           = coalesce(try(local.meta.service, null), try(local.meta.env, null), var.service, "service")
  stage_name_effective        = coalesce(try(local.meta.stage_name, null), try(local.meta.env, null), var.stage_name, "stage")
  stage_effective             = coalesce(try(local.meta.stage, null), var.stage)
  region_effective            = coalesce(try(local.meta.region, null), var.region)
  availability_zone_effective = coalesce(try(local.meta.availability_zone, null), var.availability_zone)
  name_prefix_effective       = coalesce(try(local.meta.name_prefix, null), var.name_prefix)
  keypair_name_effective_in   = coalesce(try(local.meta.keypair_name, null), var.keypair_name)
  floating_ip_pool_effective  = coalesce(try(local.meta.floating_ip_pool, null), var.floating_ip_pool)

  network_cfg      = try(local.cfg.network, {})
  vpc_cfg          = try(local.network_cfg.vpc, {})
  subnets_cfg      = try(local.network_cfg.subnets, {})
  private_subnet   = try(local.subnets_cfg.private, {})
  nat_subnet       = try(local.subnets_cfg.nat, {})
  nat_cfg          = try(local.network_cfg.nat_gateway, {})
  nat_eip_cfg      = try(local.nat_cfg.eip, {})
  nat_enabled      = try(local.nat_cfg.enabled, false)
  nat_spec         = try(local.nat_cfg.spec, 1)
  nat_snat_target  = try(local.nat_cfg.snat_target_subnet_key, "private")

  servers_cfg = try(local.cfg.servers, {})
  core_cfg    = try(local.servers_cfg.core, {})
  db_cfg      = try(local.servers_cfg.db, {})
  lb_cfg      = try(local.servers_cfg.lb, {})
}
