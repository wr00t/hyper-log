resource "alicloud_instance" "hyper-log" {
  availability_zone          = var.availability_zone
  security_groups            = alicloud_security_group.default.*.id
  instance_type              = var.ecs_type
  system_disk_category       = var.disk_category
  image_id                   = data.alicloud_images.ubuntu.ids.0
  instance_name              = "hyper-log"
  host_name                  = "hyper-log"
  vswitch_id                 = alicloud_vswitch.vsw.id
  internet_max_bandwidth_out = var.internet_max_bandwidth_out
  key_name                   = alicloud_ecs_key_pair.publickey.key_pair_name

  connection {
    host        = self.public_ip
    user        = "root"
    type        = "ssh"
    private_key = tls_private_key.temp_key.private_key_pem
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "configs/web/Caddyfile"
    destination = "/tmp/Caddyfile"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/local/bin",
      "export DEBIAN_FRONTEND=noninteractive",
      # download bin file
      "wget -O /usr/local/bin/caddy https://caddyserver.com/api/download\\?os\\=linux\\&arch\\=amd64",
      "wget -O /usr/local/bin/hyuga https://github.com/ac0d3r/Hyuga/releases/latest/download/hyuga-linux-amd64",
      "apt-get update",
      "yes | apt-get upgrade",
      # 删除阿里云盾
      ## 停止服务
      "systemctl stop aegis",
      "systemctl disable aegis",
      "rm -rf /etc/systemd/system/aegis.service",
      ## 删除启动项，以下路径不一定都存在
      "rm -f /etc/rc2.d/S80aegis",
      "rm -f /etc/rc3.d/S80aegis",
      "rm -f /etc/rc4.d/S80aegis",
      "rm -f /etc/rc5.d/S80aegis",
      "rm -f /etc/rc.d/rc2.d/S80aegis",
      "rm -f /etc/rc.d/rc3.d/S80aegis",
      "rm -f /etc/rc.d/rc4.d/S80aegis",
      "rm -f /etc/rc.d/rc5.d/S80aegis",
      "rm -f /etc/init.d/aegis",
      # 删除目录
      "rm -rf /usr/local/aegis",
      # 安装必要工具
      "apt-get install -y git",
      # 解决本地 DNS 解析问题
      "echo 'DNSStubListener=no' >> /etc/systemd/resolved.conf",
      "sed -i 's/127.0.0.53/1.1.1.1/g' /etc/resolv.conf",
      "systemctl restart systemd-resolved",
      # 安装 dnslog 平台 hyuga
      "IP=`curl myip.ipip.net/s`",
      "git clone https://github.com/Buzz2d0/Hyuga.git",
      "mv Hyuga/configs/config.toml .",
      "sed -i '0,/\"\"/s//\"${var.github_client_id}\"/g' config.toml",
      "sed -i '0,/\"\"/s//\"${var.github_client_secret}\"/g' config.toml",
      "sed -i 's/hyuga.icu/${var.main_domain}/g' config.toml",
      "sed -i 's/1.1.1.1/'$IP'/g' config.toml",
      "chmod +x /usr/local/bin/hyuga",
      "echo 'hyuga -config config.toml' | at now + 1 min",
      # 安装配置 caddy
      "chmod +x /usr/local/bin/caddy",
      "mv /tmp/Caddyfile .",
      "sed -i 's/DNGLOG_DOMAIN_NAME/log.${var.main_domain}/g' Caddyfile",
      "echo 'caddy run --watch' | at now + 1 min",
      # 配置防火墙
      "ufw allow 22",
      "ufw allow 80",
      "ufw allow 443",
      "ufw allow 53/udp",
      "echo 'ufw --force enable' | at now + 1 min",
      "touch /tmp/task.complete"
    ]
  }
}
