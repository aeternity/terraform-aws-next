terraform {
  backend "s3" {
    bucket         = "aeternity-terraform-states"
    key            = "ae-next.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}

# Default
provider "aws" {
  region = "eu-north-1"
}
