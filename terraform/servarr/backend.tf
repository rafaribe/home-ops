terraform {
  backend "s3" {
    bucket   = "terraform"
    key      = "servarr/terraform.tfstate"
    region   = "us-east-1"
    endpoint = "https://s3.rafaribe.com"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
  }
}
