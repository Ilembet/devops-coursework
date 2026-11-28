variable "zones" {
  description = "Availability zones; each gets one public and one private subnet"
  type        = list(string)
  default     = ["ru-central1-a", "ru-central1-d"]
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "course"
}

variable "allowed_ssh_cidr" {
  description = "Who may reach the bastion on port 22. Narrow it to your IP/32 when possible"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key_path" {
  description = "Public SSH key that will be allowed to log in as the ubuntu user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vm_core_fraction" {
  description = "Guaranteed vCPU share, percent (20 is the cheapest for standard-v3)"
  type        = number
  default     = 20
}

variable "preemptible" {
  description = "Preemptible VMs are much cheaper but can be stopped by the cloud at any time"
  type        = bool
  default     = true
}

variable "vm_puller_sa_id" {
  description = "ID of the vm-puller service account (pulls images from the container registry)"
  type        = string
}

variable "snapshot_cron" {
  description = "When to take snapshots, cron in UTC (default: every day at 01:00 UTC)"
  type        = string
  default     = "0 1 * * *"
}
