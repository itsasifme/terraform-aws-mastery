variable "state_bucket" {
  description = "State bucket name, used to read the network outputs"
  type        = string
}

variable "ssh_cidr" {
  description = "Your IP for SSH (x.x.x.x/32), or null to turn SSH off"
  type        = string
  default     = null
}
