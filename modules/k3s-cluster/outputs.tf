output "server_ipv4" {
  value = hcloud_server.server.ipv4_address
}

output "agent_ipv4s" {
  value = [for s in hcloud_server.agent : s.ipv4_address]
}

output "kubeconfig_fetch_command" {
  value = "ssh root@${hcloud_server.server.ipv4_address} cat /etc/rancher/k3s/k3s.yaml | sed 's/127.0.0.1/${hcloud_server.server.ipv4_address}/' > kubeconfig.yaml"
}
