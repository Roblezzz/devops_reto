terraform {
  backend "s3" {
    bucket = "digitalnaobackend"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}