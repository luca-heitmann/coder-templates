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
  default     = 10
  description = "How large would you like your workspace volume to be (in GB)?"
  validation {
    condition     = var.workspace_disk_size >= 1
    error_message = "Value must be greater than or equal to 1."
  }
}

data "coder_workspace" "me" {}

resource "coder_agent" "main" {
  os             = "linux"
  arch           = "arm64"
  startup_script = <<EOT
    #!/bin/bash

    # start juypter lab
    jupyter lab --ServerApp.token='' --ip='*' --notebook-dir /workspace &
  EOT
}

resource "coder_app" "jupyter" {
  agent_id     = coder_agent.main.id
  slug         = "jupyter"
  display_name = "JupyterLab"
  url          = "http://localhost:8888"
  icon         = "/icon/jupyter.svg"
  share        = "owner"
  subdomain    = true

  healthcheck {
    url       = "http://localhost:8888/healthz"
    interval  = 5
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
    security_context {
      run_as_user = "1000"
      fs_group    = "1000"
    }
    container {
      name    = "dev"
      image   = "ghcr.io/luca-heitmann/coder-templates/jupyterlab-template:v1.0.1"
      command = ["sh", "-c", coder_agent.main.init_script]
      security_context {
        run_as_user = "1000"
      }
      env {
        name  = "CODER_AGENT_TOKEN"
        value = coder_agent.main.token
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
