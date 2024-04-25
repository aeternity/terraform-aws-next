module "nodes_next" {
  source            = "github.com/aeternity/terraform-aws-aenode-deploy?ref=v3.1.0"
  env               = "next"

  static_nodes   = 1
  spot_nodes_min = 0
  spot_nodes_max = 0

  instance_type  = "m5.large"
  instance_types = ["m6i.large", "m5.large"]
  ami_name       = "aeternity-ubuntu-22.04-v1709639419"

  root_volume_size        = 20
  additional_storage      = true
  additional_storage_size = 40

  asg_target_groups = module.lb_next_stockholm.target_groups

  tags = {
    role  = "aenode"
    env   = "next"
  }

  config_tags = {
    vault_role        = "ae-node"
    vault_addr        = var.vault_addr
    bootstrap_version = var.bootstrap_version
    bootstrap_config  = "secret2/aenode/config/next"
  }
}

module "mdw_next" {
  source            = "github.com/aeternity/terraform-aws-aenode-deploy?ref=v3.1.0"
  env               = "next"

  static_nodes   = 1
  spot_nodes_min = 0
  spot_nodes_max = 0

  instance_type  = "t3.large"
  instance_types = ["t3.large", "c5.large", "m5.large"]
  ami_name       = "aeternity-ubuntu-22.04-v1709639419"

  root_volume_size        = 20
  additional_storage      = true
  additional_storage_size = 40

  vpc_id  = module.nodes_next.vpc_id
  subnets = module.nodes_next.subnets

  enable_mdw = true

  asg_target_groups = module.lb_next_stockholm.target_groups_mdw

  tags = {
    role  = "aemdw"
    env   = "next"
  }

  config_tags = {
    vault_role        = "ae-node"
    vault_addr        = var.vault_addr
    bootstrap_version = var.bootstrap_version
    bootstrap_config  = "secret2/aenode/config/next_mdw"
  }
}

module "lb_next_stockholm" {
  source                    = "github.com/aeternity/terraform-aws-api-loadbalancer?ref=v1.6.0"
  env                       = "next"
  fqdn                      = var.lb_fqdn
  dns_zone                  = var.dns_zone
  security_group            = module.nodes_next.sg_id
  mdw_security_group        = module.mdw_next.sg_id
  vpc_id                    = module.nodes_next.vpc_id
  subnets                   = module.nodes_next.subnets

  enable_ssl                = true
  certificate_arn           = aws_acm_certificate.cert.arn

  internal_api_enabled      = true
  state_channel_api_enabled = false
  mdw_enabled               = true
  dns_health_check          = false

  depends_on                = [aws_acm_certificate.cert]
}
