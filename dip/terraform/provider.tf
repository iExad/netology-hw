terraform {
  required_providers {
    yandex   = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = var.s3_bucket
    region     = "ru-central1"
    key        = "./terraform.tfstate"
    access_key = var.s3_access_key
    secret_key = var.s3_secret_key
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = local.vpc_zone[terraform.workspace]
}