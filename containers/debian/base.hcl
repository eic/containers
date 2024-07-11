variable "BASE_IMAGE" {
  default = null
}

variable "BUILD_IMAGE" {
  default = null
}

variable "INTERNAL_TAG" {
  default = null
}

variable "EXPORT_TAG" {
  default = null
}

variable "CI_REGISTRY" {
  default = null
}

variable "CI_PROJECT_PATH" {
  default = null
}

target "default" {
  matrix = {
    registry = [
      "${CI_REGISTRY}/${CI_PROJECT_PATH}"
    ]
  }
  name = "${replace(registry,"/","-")}"
  context = "containers/debian"
  dockerfile = "containers/debian/base.Dockerfile"
  platforms = [ "linux/amd64" ]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    BUILD_IMAGE = "${BUILD_IMAGE}"
  }
  tags = [
    "${registry}/${BUILD_IMAGE}:${INTERNAL_TAG}",
  ]
}
