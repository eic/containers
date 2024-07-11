variable "printable" { default = "a-zA-Z0-9_-" }

variable "BASE_IMAGE" { default = null }
variable "BUILD_IMAGE" { default = null }

variable "INTERNAL_TAG" { default = null }
variable "EXPORT_TAG" { default = null }

variable "CI_PUSH" { default = null }
variable "CI_REGISTRY" { default = null }
variable "CI_PROJECT_PATH" { default = null }

variable "DH_PUSH" { default = null }
variable "DH_REGISTRY" { default = null }
variable "DH_REGISTRY_USER" { default = null }

variable "GH_PUSH" { default = null }
variable "GH_REGISTRY" { default = null }
variable "GH_REGISTRY_USER" { default = null }

registries = compact([
  CI_PUSH != null && CI_PUSH != "" ? "${CI_REGISTRY}/${CI_PROJECT_PATH}" : null,
  DH_PUSH != null && DH_PUSH != "" ? "${DH_REGISTRY}/${DH_REGISTRY_USER}" : null,
  GH_PUSH != null && GH_PUSH != "" ? "${GH_REGISTRY}/${GH_REGISTRY_USER}" : null,
])
