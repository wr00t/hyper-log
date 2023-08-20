# Add a record to the domain
resource "cloudflare_record" "a_record" {
  zone_id = var.cloudflare_zone_id
  name    = "ns"
  type    = "A"
  value   = alicloud_instance.hyper-log.public_ip
  ttl     = 1
  proxied = false
}

# 虚拟网络
resource "alicloud_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"
}

# 虚拟交换机
resource "alicloud_vswitch" "vsw" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "172.16.0.0/24"
  zone_id    = var.availability_zone
}

# 安全组
resource "alicloud_security_group" "default" {
  vpc_id = alicloud_vpc.vpc.id
}

# 安全组规则
resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

# 允许 nebula 的 UDP 流量
resource "alicloud_security_group_rule" "allow_all_udp" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "local_file" "temp_key" {
  filename = "keys/temp_key.pem"
  content  = tls_private_key.temp_key.private_key_pem
}
