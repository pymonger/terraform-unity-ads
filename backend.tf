terraform {
  backend "s3" {
    bucket               = "unity-unity-dev-bucket"
    workspace_key_prefix = "ads/tfstates"
    key                  = "terraform.tfstate"
    region               = "us-west-2"
    encrypt              = true
  }
}
