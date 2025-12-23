terraform {
  required_version = ">= 1.3.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}

provider "null" {}

locals {
  env_name = "${var.service}-${var.stage_name}${var.stage}"
}

resource "null_resource" "placeholder" {
  triggers = {
    env = local.env_name
  }
}
