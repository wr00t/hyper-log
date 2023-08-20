# 域名配置
variable "main_domain" {
  type        = string
  description = "根域名"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare 域名 ID"
}

variable "cloudflare_api_token" {
  type        = string
  description = "cloudflare api token"
}

# github 认证配置
variable "github_client_id" {
  type        = string
  description = "github client id for OAuth"
}

variable "github_client_secret" {
  type        = string
  description = "github client secret for OAuth"
}

# 配置阿里云资源信息
variable "alicloud_access_key" {
  type        = string
  description = "alicloud access key"
}

variable "alicloud_secret_key" {
  type        = string
  description = "alicloud secret key"
}

variable "alicloud_region" {
  type        = string
  description = "alicloud ecs region"
  default     = "cn-hongkong"
}

# 设置阿里云区域可用机房
variable "availability_zone" {
  type        = string
  description = "The available zone to launch ecs instance and other resources."
  default     = "cn-hongkong-c"
}

# 根据区域设置 ECS 实例类型
variable "ecs_type" {
  type    = string
  default = "ecs.t5-lc2m1.nano"
}

# 指定 ECS 实例磁盘类型，这里为普通云盘
variable "disk_category" {
  type    = string
  default = "cloud_efficiency"
}

# 设置磁盘大小
variable "disk_size" {
  type    = string
  default = "40"
}

# 设置上网扣费方式，默认为 PayByTraffic (按流量计费)
variable "internet_charge_type" {
  type    = string
  default = "PayByTraffic"
}

# 公共网络最大传出带宽，从1.7版本，默认设置大于0会自动申请独享公网IP地址
variable "internet_max_bandwidth_out" {
  default = 5
}
