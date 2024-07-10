variable "BASE_IMAGE" {
  default = "${BASE_IMAGE}"
}

variable "BUILD_IMAGE" {
  default = "${BUILD_IMAGE}"
}

variable "INTERNAL_TAG" {
  default = "${INTERNAL_TAG}"
}

variable "EXPORT_TAG" {
  default = "${EXPORT_TAG}"
}

target "default" {
  context = "containers/debian"
  dockerfile = "containers/debian/base.Dockerfile"
  platforms = [
    "linux/amd64"
  ]
  BASE_IMAGE = "${BASE_IMAGE}"
  BUILD_IMAGE = "${BUILD_IMAGE}"
  tags = [
    "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}:${INTERNAL_TAG}",
    ""
  ]
}
