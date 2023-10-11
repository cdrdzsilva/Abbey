terraform {
  backend "http" {
    address        = "https://api.abbey.io/terraform-http-backend"
    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.6"
    }
  }
}

provider "abbey" {
  # Configuration options
  bearer_auth = var.abbey_token
}

resource "abbey_grant_kit" "DJ_demo" {
  name = "DJ_demo"
  description = "Demo "

  workflow = {
    steps = [
      {
        reviewers = {
          one_of = [
            "cdrdzsilva@gmail.com"
          ]
        }
      }
    ]
  }

  policies = [
    {
      query = <<-EOT
        package common
        
        import data.abbey.functions
        
        allow[msg] {
          functions.expire_after("5m")
          msg := sprintf("granting access for %s", ["5m"])
        }
      EOT
    }
  ]

  output = {
    location = "github://cdrdzsilva/abbey/access.tf"
    append = <<-EOT
      resource "abbey_demo" "grant_read_write_access" {
        permission = "read_write"
        email = "{{ .data.system.abbey.identities.abbey.email }}"
      }
    EOT
  }
}
