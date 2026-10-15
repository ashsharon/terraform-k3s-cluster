output "server_ipv4" {
  value       = module.k3s.server_ipv4
  description = "Public IPv4 of the k3s control-plane node."
}

output "agent_ipv4s" {
  value       = module.k3s.agent_ipv4s
  description = "Public IPv4s of every k3s agent node."
}

output "kubeconfig_fetch_command" {
  value       = module.k3s.kubeconfig_fetch_command
  description = "Run this locally to pull a working kubeconfig off the control-plane node."
}
