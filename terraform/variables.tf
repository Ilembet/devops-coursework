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
