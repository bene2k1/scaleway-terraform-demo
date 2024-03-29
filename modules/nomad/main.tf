variable "server_count" {
  default     = "2"
  description = "The number of nomad servers to launch."
}

variable "image" {}

variable "type" {
  default     = "DEV1-S"
  description = "Scaleway Instance type, if you change, make sure it is compatible with AMI, not all AMIs allow all instance types "
}

variable "consul_cluster_ip" {
  description = "ip to consul cluster. Port is assumed to be 8500"
}

variable "security_group" {
  description = "Security Group to place servers in"
}

variable "bastion_host" {
  description = "IP of bastion host used for provisioning"
}

resource "scaleway_instance_server" "server" {
  count               = "${var.server_count}"
  name                = "nomad-${count.index + 1}"
  image               = "${var.image}"
  type                = "${var.type}"
  tags                = ["cluster"]

  connection {
    type         = "ssh"
    user         = "root"
    host         = "${self.private_ip}"
    bastion_host = "${var.bastion_host}"
    bastion_user = "root"
    agent        = true
  }
  provisioner "file" {
    source      = "${path.module}/scripts/system.service"
    destination = "/tmp/nomad.service"
  }

  provisioner "remote-exec" {
    inline = [ 
      <<CMD
cat > /tmp/server.hcl <<EOF
datacenter = "dc1"
bind_addr = "${self.private_ip}"
advertise {
  # We need to specify our host's IP because we can't
  # advertise 0.0.0.0 to other nodes in our cluster.
  serf = "${self.private_ip}:4648"
  rpc  = "${self.private_ip}:4647"
  http = "${self.private_ip}:4646"
}
server {
  enabled = true
  bootstrap_expect = ${var.server_count}
}
client {
  enabled = true
  options = {
    "driver.raw_exec.enable" = "1"
  }
}
consul {
  address = "${var.consul_cluster_ip}:8500"
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}
EOF
CMD
    ]
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install.sh",
      "${path.module}/scripts/service.sh",
    ]
  }

  security_group_id = var.security_group
}

output "public_ips" {
  value = "${list(scaleway_instance_server.server.*.public_ip)}"
}

output "private_ips" {
  value = "${list(scaleway_instance_server.server.*.private_ip)}"
}