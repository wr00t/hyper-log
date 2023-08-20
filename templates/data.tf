data "alicloud_images" "ubuntu" {
  most_recent = true
  name_regex  = "^ubuntu_20.*x64"
}
