# Helper to map onto printable target names
variable "printable" { default = "a-zA-Z0-9_-" }

# Internal tag (never pushed)
variable "INTERNAL_TAG" { default = "testing" }
# External tag (pushed to registries)
variable "EXPORT_TAG" { default = null }

# Local registry
variable "CI_PUSH" { default = null }
variable "CI_REGISTRY" { default = null }
variable "CI_PROJECT_PATH" { default = null }

# Docker Hub
variable "DH_PUSH" { default = null }
variable "DH_REGISTRY" { default = null }
variable "DH_REGISTRY_USER" { default = null }

# GitHub Container Registry
variable "GH_PUSH" { default = null }
variable "GH_REGISTRY" { default = null }
variable "GH_REGISTRY_USER" { default = null }

# List of enabled registries
registries = compact([
  CI_PUSH != null && CI_PUSH != "" ? "${CI_REGISTRY}/${CI_PROJECT_PATH}" : null,
  DH_PUSH != null && DH_PUSH != "" ? "${DH_REGISTRY}/${DH_REGISTRY_USER}" : null,
  GH_PUSH != null && GH_PUSH != "" ? "${GH_REGISTRY}/${GH_REGISTRY_USER}" : null,
])
