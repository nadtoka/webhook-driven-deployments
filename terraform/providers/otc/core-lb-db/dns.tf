locals {
  fqdn_core = var.dns_record_name != "" ? "core.${var.dns_record_name}" : ""
  fqdn_db   = var.dns_record_name != "" ? "db.${var.dns_record_name}" : ""
  fqdn_lb   = var.dns_record_name != "" ? "lb.${var.dns_record_name}" : ""
}

resource "opentelekomcloud_dns_recordset_v2" "core" {
  count       = var.enable_dns && var.dns_zone_id != "" && local.fqdn_core != "" ? 1 : 0
  zone_id     = var.dns_zone_id
  name        = local.fqdn_core
  description = "Core node"
  type        = "A"
  ttl         = 300
  records     = [local.public_hosts.core]
}

resource "opentelekomcloud_dns_recordset_v2" "db" {
  count       = var.enable_dns && var.dns_zone_id != "" && local.fqdn_db != "" ? 1 : 0
  zone_id     = var.dns_zone_id
  name        = local.fqdn_db
  description = "Database node"
  type        = "A"
  ttl         = 300
  records     = [local.public_hosts.db]
}

resource "opentelekomcloud_dns_recordset_v2" "lb" {
  count       = var.enable_dns && var.dns_zone_id != "" && local.fqdn_lb != "" ? 1 : 0
  zone_id     = var.dns_zone_id
  name        = local.fqdn_lb
  description = "Load balancer node"
  type        = "A"
  ttl         = 300
  records     = [local.public_hosts.lb]
}
