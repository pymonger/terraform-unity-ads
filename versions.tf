terraform {
  required_version = "~> 1.8.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.72.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3.5"
    }
    external = {
      source  = "hashicorp/external"
      version = ">=2.3.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.16.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.33.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.5.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.12.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.6"
    }
  }
}
