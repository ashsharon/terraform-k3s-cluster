variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token. Set via TF_VAR_hcloud_token or a .auto.tfvars file — never commit it (see .gitignore)."
}

variable "cluster_name" {
  type        = string
  default     = "icp-k3s"
  description = "Prefix used for every resource name (servers, network, firewall)."
}

variable "location" {
  type        = string
  default     = "nbg1"
  description = "Hetzner datacenter: nbg1, fsn1, hel1, ash, or hil."
}

variable "ssh_public_key_path" {
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
  description = "Public key installed on every node for SSH access."
}

variable "admin_cidr" {
  type        = string
  description = "CIDR allowed to reach SSH (22) and the k3s API (6443) — your own public IP/32. Find it with `curl ifconfig.me`."
}

variable "server_type" {
  type        = string
  default     = "cx22"
  description = "Hetzner server type for the k3s control-plane node."
}

variable "agent_server_type" {
  type        = string
  default     = "cx22"
  description = "Hetzner server type for each k3s agent (worker) node."
}

variable "agent_count" {
  type        = number
  default     = 2
  description = "Number of k3s agent nodes to provision alongside the control-plane node."
}

variable "private_network_iface" {
  type        = string
  default     = "enp7s0"
  description = "NIC name flannel should bind to on the private network. Verify per image/server type with `ip a` after first boot — this varies across Hetzner server types and isn't guaranteed to stay enp7s0."
}
