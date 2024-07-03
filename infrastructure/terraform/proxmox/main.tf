terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "proxmox/terraform.tfstate"
    region = "us-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
