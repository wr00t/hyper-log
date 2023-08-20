terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "alicloud" {
  access_key = var.alicloud_access_key
  secret_key = var.alicloud_secret_key
  region     = var.alicloud_region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
