variable "service" {
  type        = string
  description = "Service name used for naming resources."
  default     = ""
}

variable "config_path" {
  type        = string
  description = "Path to YAML config supplying inputs; defaults to ./config.yml."
  default     = "./config.yml"
}

variable "stage_name" {
  type        = string
  description = "Stage identifier (e.g., pr123)."
  default     = ""
}

variable "stage" {
  type        = string
  description = "Optional stage suffix (e.g., -blue)."
  default     = ""
}

variable "region" {
  type        = string
  description = "Open Telekom Cloud region."
  default     = "eu-de"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for instances."
  default     = "eu-de-01"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the subnet."
  default     = "10.0.1.0/24"
}

variable "subnet_gateway_ip" {
  type        = string
  description = "Gateway IP for the subnet."
  default     = "10.0.1.1"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH to instances. Restrict in real deployments."
  default     = "0.0.0.0/0"
}

variable "ssh_user" {
  type        = string
  description = "SSH username for Kitchen and SSH access."
  default     = "ubuntu"
}

variable "ssh_port" {
  type        = number
  description = "SSH port."
  default     = 22
}

variable "image_id" {
  type        = string
  description = "Image ID to use for all instances."
  default     = ""

  validation {
    condition = (
      length(var.image_id) > 0 ||
      anytrue([
        for image in [
          try(try(yamldecode(file(var.config_path)), {}).servers.core.image_id, ""),
          try(try(yamldecode(file(var.config_path)), {}).servers.db.image_id, ""),
          try(try(yamldecode(file(var.config_path)), {}).servers.lb.image_id, "")
        ] : length(image) > 0
      ])
    )
    error_message = "Provide image_id via var.image_id or servers.<role>.image_id in config.yml."
  }
}

variable "default_flavor_id" {
  type        = string
  description = "Default flavor ID for instances. Override per role as needed."
  default     = "s3.large.2"

  validation {
    condition     = length(var.default_flavor_id) > 0
    error_message = "Provide a flavor ID supported in your OTC project."
  }
}

variable "flavor_id_core" {
  type        = string
  description = "Optional override flavor ID for the core instance."
  default     = ""
}

variable "flavor_id_db" {
  type        = string
  description = "Optional override flavor ID for the db instance."
  default     = ""
}

variable "flavor_id_lb" {
  type        = string
  description = "Optional override flavor ID for the load balancer instance."
  default     = ""
}

variable "name_prefix" {
  type        = string
  description = "Optional name prefix for resources; defaults to service-stage combination."
  default     = ""
}

variable "keypair_name" {
  type        = string
  description = "Base name for the created keypair. Defaults to the environment name when empty."
  default     = ""
}

variable "use_keypair_workaround" {
  type        = bool
  description = "Set true to reuse an existing keypair/public key instead of generating one."
  default     = false
}

variable "existing_keypair_name" {
  type        = string
  description = "Existing keypair name to reuse when use_keypair_workaround is true."
  default     = ""
}

variable "existing_public_key" {
  type        = string
  description = "Existing public key material to use when use_keypair_workaround is true and a key needs to be created."
  default     = ""
}

variable "enable_floating_ip" {
  type        = bool
  description = "Attach floating IPs for external connectivity."
  default     = true
}

variable "floating_ip_pool" {
  type        = string
  description = "Floating IP pool name."
  default     = "admin_external_net"
}

variable "instance_tags" {
  type        = map(string)
  description = "Optional tags to attach to instances."
  default     = {}
}

variable "enable_dns" {
  type        = bool
  description = "Create DNS records for instances."
  default     = false
}

variable "dns_zone_id" {
  type        = string
  description = "Existing DNS zone ID for optional records."
  default     = ""
}

variable "dns_record_name" {
  type        = string
  description = "Record name to create when enable_dns is true."
  default     = ""
}
