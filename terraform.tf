provider "scaleway" {
  region = "ams1"
}

data "scaleway_image" "ubuntu" {
  architecture = "arm64"
  name         = "CentOS 7.3"
}

resource "scaleway_ip" "myvpn" {
  server = "${scaleway_server.myvpn.id}"
}

resource "scaleway_server" "myvpn" {
  name                = "myvpn"
  image               = "${data.scaleway_image.ubuntu.id}"
  type                = "ARM64-2GB"
  security_group      = "${scaleway_security_group.vpn.id}"
  tags                = ["openvpn"]
  dynamic_ip_required = true
}

resource "scaleway_security_group" "vpn" {
  name        = "VPN"
  description = "Allow SSH & VPN traffic"
}

resource "scaleway_security_group_rule" "http_accept" {
  security_group = "${scaleway_security_group.vpn.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 22
}

resource "scaleway_security_group_rule" "https_accept" {
  security_group = "${scaleway_security_group.vpn.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "UDP"
  port      = 1194
}

output "Public IP Address:" {
  value = "${scaleway_ip.myvpn.ip}"
}

resource "local_file" "host" {
  content  = "[myvpn]\n${scaleway_ip.myvpn.ip}\n"
  filename = "hosts"
}
