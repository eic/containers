target "default" {
  matrix = {
    registry = registries
  }
  name = "${regex_replace(registry,"[^a-zA-Z0-9_-]","-")}"
  context = "containers/debian"
  dockerfile = "base.Dockerfile"
  platforms = [ "linux/amd64" ]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    BUILD_IMAGE = "${BUILD_IMAGE}"
  }
  tags = compact([
    "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}:${INTERNAL_TAG}",
    EXPORT_TAG != null ? "${registry}/${BUILD_IMAGE}:${EXPORT_TAG}" : null,
  ])
}
