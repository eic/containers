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

target "default" {
  context = "containers/debian"
  dockerfile = "containers/debian/base.Dockerfile"
  platforms = [ "linux/amd64" ]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    BUILD_IMAGE = "${BUILD_IMAGE}"
  }
  tags = [
    "${BUILD_IMAGE}:${INTERNAL_TAG}",
  ]
}
