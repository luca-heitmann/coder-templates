terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.1"
    }
  }
}

variable "namespace" {
  type        = string
  default     = "coder-1"
  sensitive   = true
}

variable "workspace_disk_size" {
  type        = number
  default     = 15
  description = "How large would you like your workspace volume to be (in GB)?"
  validation {
    condition     = var.workspace_disk_size >= 1
    error_message = "Value must be greater than or equal to 1."
  }
}

variable "dotfiles_uri" {
  type        = string
  default     = "https://github.com/luca-heitmann/dotfiles.git"
  description = "Dotfiles repo"
}

data "coder_workspace" "me" {}

resource "coder_agent" "main" {
  os             = "linux"
  arch           = "arm64"
  startup_script = <<EOT
    #!/bin/bash

    sudo chown -R coder:coder /workspace
    coder dotfiles -y ${var.dotfiles_uri}
    code-server --disable-telemetry --auth none --port 13337 &
  EOT
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  icon         = "/icon/code.svg"
  url          = "http://localhost:13337?folder=/workspace"
  subdomain    = true
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 3
    threshold = 10
  }
}

resource "kubernetes_persistent_volume_claim" "workspace" {
  metadata {
    name      = "coder-${lower(data.coder_workspace.me.owner)}-${lower(data.coder_workspace.me.name)}-workspace"
    namespace = var.namespace
  }
  wait_until_bound = false
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "${var.workspace_disk_size}Gi"
      }
    }
  }
}

resource "kubernetes_pod" "main" {
  count = data.coder_workspace.me.start_count
  metadata {
    name      = "coder-${lower(data.coder_workspace.me.owner)}-${lower(data.coder_workspace.me.name)}"
    namespace = var.namespace
  }
  spec {
    service_account_name = "coder"
    container {
      name  = "docker-sidecar"
      image = "docker:dind"
      security_context {
        privileged = true
      }
      command = ["dockerd", "-H", "tcp://127.0.0.1:2375"]
    }
    container {
      name    = "dev"
      image   = "ghcr.io/luca-heitmann/coder-templates/devops-template:v1.0.0"
      command = ["sh", "-c", coder_agent.main.init_script]
      security_context {
        run_as_user = "1000"
      }
      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.main.token
      }
      env {
        name  = "DOCKER_HOST"
        value = "localhost:2375"
      }
      volume_mount {
        mount_path = "/workspace"
        name       = "workspace"
        read_only  = false
      }
    }
    volume {
      name = "workspace"
      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.workspace.metadata.0.name
        read_only  = false
      }
    }
  }
}
