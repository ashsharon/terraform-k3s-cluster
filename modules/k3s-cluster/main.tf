# A single control-plane node + N agent nodes, wired together over a
# Hetzner private network, bootstrapped into a k3s cluster via cloud-init.
# No provisioners, no SSH-after-create step: everything needed to join the
# cluster (the shared token, the control-plane's private IP) is baked into
# the cloud-init user_data at create time.

resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

resource "hcloud_ssh_key" "default" {
  name       = "${var.cluster_name}-key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_network" "private" {
  name     = "${var.cluster_name}-net"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "private" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

resource "hcloud_firewall" "k3s" {
  name = "${var.cluster_name}-fw"

  # Admin access: only from the operator's own IP.
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [var.admin_cidr]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = [var.admin_cidr]
  }

  # Ingress traffic: open to the world, same as any public-facing app.
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "server" {
  name         = "${var.cluster_name}-server"
  server_type  = var.server_type
  image        = "ubuntu-22.04"
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.k3s.id]

  network {
    network_id = hcloud_network.private.id
    ip         = "10.0.1.10"
  }

  user_data = templatefile("${path.module}/cloud-init/server.yaml.tftpl", {
    k3s_token     = random_password.k3s_token.result
    private_ip    = "10.0.1.10"
    private_iface = var.private_network_iface
  })

  depends_on = [hcloud_network_subnet.private]
}

resource "hcloud_server" "agent" {
  count        = var.agent_count
  name         = "${var.cluster_name}-agent-${count.index}"
  server_type  = var.agent_server_type
  image        = "ubuntu-22.04"
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.k3s.id]

  network {
    network_id = hcloud_network.private.id
    ip         = "10.0.1.${20 + count.index}"
  }

  user_data = templatefile("${path.module}/cloud-init/agent.yaml.tftpl", {
    k3s_token         = random_password.k3s_token.result
    server_private_ip = "10.0.1.10"
    private_iface     = var.private_network_iface
  })

  depends_on = [hcloud_server.server]
}
