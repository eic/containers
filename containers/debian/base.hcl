target "default" {
  attest = [
    "type=provenance,disabled=true"
  ]
  context = "containers/debian"
  dockerfile = "base.Dockerfile"
  platforms = [ "linux/amd64" ]
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
    BUILD_IMAGE = "${BUILD_IMAGE}"
  }
  tags = compact(flatten([
    "${CI_REGISTRY}/${CI_PROJECT_PATH}/${BUILD_IMAGE}:${INTERNAL_TAG}",
    EXPORT_TAG != null ? [ for registry in registries: "${registry}/${BUILD_IMAGE}:${EXPORT_TAG}" ] : null,
  ]))
}
