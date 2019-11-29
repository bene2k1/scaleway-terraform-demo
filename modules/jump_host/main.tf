variable "image" {}

variable "security_group" {
  description = "Security Group to place servers in"
}

variable "type" {
  default     = "DEV1-S"
  description = "Scaleway Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

resource "scaleway_instance_server" "jump_host" {
  name                = "jump_host"
  image               = "${var.image}"
  type                = "${var.type}"

  tags = ["jump_host"]

  security_group_id = var.security_group
}

resource "scaleway_instance_ip" "jump_host" {
  server_id = "${scaleway_instance_server.jump_host.id}"
}

output "public_ip" {
  value = "${scaleway_instance_ip.jump_host.address}"
}
