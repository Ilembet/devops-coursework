terraform {
  required_version = ">= 1.6.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }

  # State lives in the same bucket as the portfolio, under its own key.
  # Credentials come from AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (env.sh).
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "tfstate-ilembet-portfolio"
    region = "ru-central1"
    key    = "coursework/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# cloud_id, folder_id and token come from YC_CLOUD_ID, YC_FOLDER_ID, YC_TOKEN (env.sh)
provider "yandex" {
  zone = var.zones[0]
}
