terraform { 
  required_providers { 
    aws = { 
      source = "hashicorp/aws" 
      version = "~> 6.0" 
    } 
    docker = { 
      source = "kreuzwerker/docker" 
      version = "4.2.0" 
    } 
  } 
} 

provider "aws" { 
  region = "us-east-1" 
  shared_credentials_files = ["./credentials"] 
  default_tags {
    tags = {
        Course       = "CSSE6400"
        Name         = "TaskOverflow"
        Automation   = "Terraform"
    }
  }
}

data "aws_ecr_authorization_token" "ecr_token" {} 

provider "docker" {
  registry_auth {
    address = data.aws_ecr_authorization_token.ecr_token.proxy_endpoint 
    username = data.aws_ecr_authorization_token.ecr_token.user_name 
    password = data.aws_ecr_authorization_token.ecr_token.password 
  }
}

resource "aws_ecr_repository" "taskoverflow" { 
  name = "taskoverflow" 
  force_delete = true  # Allow Terraform to destory ECR repo while it still contains the TaskOverflow image.
}

data "aws_iam_role" "lab" {
  name = "LabRole"
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
