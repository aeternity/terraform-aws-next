variable "vault_addr" {
  description = "Vault server URL address"
}

variable "bootstrap_version" {
  default = "v4.3.0"
}

variable "dns_zone" {
  default = "ZSEEAAX46MKWZ"
}

variable "lb_fqdn" {
  default = "next.aeternity.io"
}
