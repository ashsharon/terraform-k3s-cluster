# Every module that uses a non-default-namespace provider (anything other
# than hashicorp/<name>) must declare its own required_providers block -
# Terraform does not inherit the source address from the root module, only
# the version constraint resolution. Without this, Terraform assumes the
# legacy "hashicorp/hcloud" namespace for the "hcloud" local name used
# below and fails to find a matching provider.

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
