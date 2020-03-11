terraform {
  required_version = "= 0.11.14"
}

provider "aws" {
  version = "= 2.52.0"
  region  = "${var.aws_region}"
}

provider "null" {
  version = "= 2.1.2"
}
