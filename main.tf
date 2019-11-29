variable "commercial_type" {
  default = "DEV1-S"
  description = "Scaleway Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "architectures" {
  default = {
    DEV1-S  = "x86_64"
    DEV1-M  = "x86_64"
    DEV1-L  = "x86_64"
    DEV1-XL = "x86_64"
    GP1-XS  = "x86_64"
    GP1-S   = "x86_64"
    GP1-M   = "x86_64"
    GP1-L   = "x86_64"
    GP1-XL  = "x86_64"
  }
}

data "scaleway_image" "ubuntu" {
  architecture = var.architectures[var.commercial_type]
  name         = "Ubuntu Bionic"
}

provider "scaleway" {
  access_key      = "<SCW-ACCESS-KEY>"
  secret_key      = "<SCW-SECRET_KEY>"
  organization_id = "<SCW-ORGANIZATION-ID>"
  zone            = "fr-par-1"
  region          = "fr-par"
}

module "security_group" {
  source = "./modules/security_group"
}

module "jump_host" {
  source = "./modules/jump_host"

  security_group = module.security_group.id

  type  = var.commercial_type
  image = data.scaleway_image.ubuntu.id
}

module "consul" {
  source = "./modules/consul"

  security_group = module.security_group.id
  bastion_host   = module.jump_host.public_ip

  type  = var.commercial_type
  image = data.scaleway_image.ubuntu.id
}

module "nomad" {
  source            = "./modules/nomad"
  consul_cluster_ip = module.consul.server_ip
  security_group    = module.security_group.id
  bastion_host   = module.jump_host.public_ip

  type  = var.commercial_type
  image = data.scaleway_image.ubuntu.id
}
