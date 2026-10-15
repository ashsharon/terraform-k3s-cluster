module "k3s" {
  source = "./modules/k3s-cluster"

  cluster_name          = var.cluster_name
  location              = var.location
  ssh_public_key_path   = var.ssh_public_key_path
  admin_cidr            = var.admin_cidr
  server_type           = var.server_type
  agent_server_type     = var.agent_server_type
  agent_count           = var.agent_count
  private_network_iface = var.private_network_iface
}
