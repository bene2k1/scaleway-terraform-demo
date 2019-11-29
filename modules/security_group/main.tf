# security group rules seem to work like iptables: the order of
# accept and drop is important. also, the security groups should be created
# before you start spawning any servers
resource "scaleway_instance_security_group" "cluster" {
  name        = "cluster"
  description = "cluster-sg"

  inbound_default_policy    = "accept"

  # NOTE this is just a guess - might not work for you
  inbound_rule {
  action   = "accept"
  ip_range = "10.0.0.0/8"
  protocol = "TCP"
  port     = "4646"
 }

  inbound_rule {
  action   = "accept"
  ip_range = "10.0.0.0/8"
  protocol = "TCP"
  port     = "4647"
 }

  inbound_rule {
  action   = "accept"
  ip_range = "10.0.0.0/8"
  protocol = "TCP"
  port     = "4648"
 }

  inbound_rule {
  action    = "drop"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port  = "4646"
 } 

  inbound_rule {
  action    = "drop"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port  = "4647"
 }

  inbound_rule {
  action    = "drop"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port  = "4648"
 }
}
 output "id" {
  value = "${scaleway_instance_security_group.cluster.id}"
}
