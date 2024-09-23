# Variables which are required to be defined
variable "jobs" { default = 1 }
variable "ENV" { default = "xl" }
variable "BUILD_IMAGE" { default = "eic_" }
variable "BUILD_TYPE" { default = "default" }

# Variables whose defaults can be overridden on build
variable "DOCKER_REGISTRY" { default = join("/", [ CI_REGISTRY, CI_PROJECT_PATH, ""]) }
variable "BUILDER_IMAGE" { default = null }
variable "RUNTIME_IMAGE" { default = null }

variable "S3_ACCESS_KEY" { default = null }
variable "S3_SECRET_KEY" { default = null }

variable "NIGHTLY" { default = null }
variable "NIGHTLY_TAG" { default = null }

variable "EDM4EIC_VERSION" { default = null }
variable "EICRECON_VERSION" { default = null }
variable "EPIC_VERSION" { default = null }
variable "JUGGLER_VERSION" { default = null }

variable "CI_COMMIT_SHA" { default = null }

image_name = BUILD_TYPE == "default" ? "${BUILD_IMAGE}${ENV}" : "${BUILD_IMAGE}${ENV}-${BUILD_TYPE}"
image_names = [
  image_name,
  replace(image_name,"eic","jug")
]

target "default" {
  attest = [
    "type=provenance,disabled=true"
  ]
  context = "containers/jug"
  contexts = {
    spack-environment = "spack-environment"
  }
  dockerfile = "dev.Dockerfile"
  platforms = [ "linux/amd64" ]
  secret = [
    "id=mirrors,src=mirrors.yaml",
  ]
  args = {
    ENV = ENV
    jobs = jobs
    DOCKER_REGISTRY = DOCKER_REGISTRY
    BUILDER_IMAGE = BUILDER_IMAGE
    RUNTIME_IMAGE = RUNTIME_IMAGE
    INTERNAL_TAG = INTERNAL_TAG
    SPACK_ORGREPO = try(SPACK_ORGREPO, null)
    SPACK_VERSION = try(SPACK_VERSION, null)
    SPACK_CHERRYPICKS = join("\n", try(SPACK_CHERRYPICKS, []))
    SPACK_CHERRYPICKS_FILES = join("\n", try(SPACK_CHERRYPICKS_FILES, []))
    KEY4HEPSPACK_ORGREPO = try(KEY4HEPSPACK_ORGREPO, null)
    KEY4HEPSPACK_VERSION = try(KEY4HEPSPACK_VERSION, null)
    EICSPACK_ORGREPO = try(EICSPACK_ORGREPO, null)
    EICSPACK_VERSION = try(EICSPACK_VERSION, null)
    S3_ACCESS_KEY = S3_ACCESS_KEY
    S3_SECRET_KEY = S3_SECRET_KEY
    EDM4EIC_VERSION = BUILD_TYPE == "default" ? EDM4EIC_VERSION : "main"
    EICRECON_VERSION = BUILD_TYPE == "default" ? EICRECON_VERSION : "main"
    EPIC_VERSION = BUILD_TYPE == "default" ? EPIC_VERSION : "main"
    JUGGLER_VERSION = BUILD_TYPE == "default" ? JUGGLER_VERSION : "main"
  }
  tags = compact(flatten([
    [
      for image_name in image_names:
        join("/", compact([ CI_REGISTRY, CI_PROJECT_PATH, "${image_name}:${INTERNAL_TAG}"]) )
    ],
    EXPORT_TAG != null && EXPORT_TAG != "" ? [
      for registry_image_name in setproduct(registries, image_names):
        format("%s:%s", join("/", registry_image_name), EXPORT_TAG )
    ] : [ null ]
  ]))
}
