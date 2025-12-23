variable "service" {
  type        = string
  description = "Service name"
}

variable "stage_name" {
  type        = string
  description = "Stage name (e.g., pr123)"
}

variable "stage" {
  type        = string
  description = "Optional stage suffix (e.g., -blue)"
  default     = ""
}

variable "dns" {
  type        = string
  description = "Optional DNS name for the environment"
  default     = ""
}
