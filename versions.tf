terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
    sdm = {
      source  = "strongdm/sdm"
      version = ">= 1.0.39"
    }
  }
}
