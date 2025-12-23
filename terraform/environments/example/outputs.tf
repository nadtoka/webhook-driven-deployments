output "ssh_host" {
  value       = var.dns != "" ? var.dns : "127.0.0.1"
  description = "Placeholder SSH host"
}

output "ssh_user" {
  value       = "ubuntu"
  description = "Placeholder SSH user"
}

output "ssh_port" {
  value       = 22
  description = "Placeholder SSH port"
}

output "ssh_private_key" {
  value       = ""
  description = "Optional inline private key content"
  sensitive   = true
}

output "ssh_key_path" {
  value       = ""
  description = "Optional existing key path if not using inline key"
}
