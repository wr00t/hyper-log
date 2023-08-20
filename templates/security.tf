resource "random_string" "random" {
  length  = 16
  special = true
}

resource "tls_private_key" "temp_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "alicloud_ecs_key_pair" "publickey" {
  public_key = chomp(tls_private_key.temp_key.public_key_openssh)
}
