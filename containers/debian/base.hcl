# Variables which are required to be defined
variable "jobs" { default = 1 }
variable "BUILD_IMAGE" { default = "debian_base" }

# Variables whose defaults can be overridden on build
variable "BASE_IMAGE" { default = null }

# docker/metadata-action overrides the following target with tags
# but we implement it for use outside docker/metadata-action
target "docker-metadata-action" {
  tags = compact(flatten([
    join("/", compact([ CI_REGISTRY, CI_PROJECT_PATH, "${BUILD_IMAGE}:${INTERNAL_TAG}"]) ),
    EXPORT_TAG != null && EXPORT_TAG != "" ? [
      for registry in registries: "${registry}/${BUILD_IMAGE}:${EXPORT_TAG}"
    ] : [ null ]
  ]))
}

target "default" {
  inherits = ["docker-metadata-action"]
  attest = [
    "type=provenance,disabled=true"
  ]
  context = "containers/debian"
  dockerfile = "base.Dockerfile"
  platforms = [ "linux/amd64" ]
  args = {
    jobs = jobs
    BASE_IMAGE = BASE_IMAGE
    BUILD_IMAGE = BUILD_IMAGE
  }
}
