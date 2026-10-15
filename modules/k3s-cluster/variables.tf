variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "admin_cidr" {
  type = string
}

variable "server_type" {
  type = string
}

variable "agent_server_type" {
  type = string
}

variable "agent_count" {
  type = number
}

variable "private_network_iface" {
  type = string
}
