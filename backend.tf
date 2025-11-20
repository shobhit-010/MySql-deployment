terraform {
  backend "s3" {
    bucket         = "shobhit-mysql-tf-state"
    key            = "infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "shobhit-mysql-tf-lock"
  }
}
