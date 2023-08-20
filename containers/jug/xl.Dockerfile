#syntax=docker/dockerfile:1.4
ARG DOCKER_REGISTRY="eicweb/"
ARG BASE_IMAGE="jug_dev"
ARG INTERNAL_TAG="testing"

## ========================================================================================
## STAGE1: spack builder image
## EIC builder image with spack
## ========================================================================================
FROM ${DOCKER_REGISTRY}${BASE_IMAGE}:${INTERNAL_TAG}
ARG TARGETPLATFORM

## version will automatically bust cache for nightly, as it includes
## the date
ARG JUG_VERSION=1

RUN echo " - jug_xl: ${JUG_VERSION}" >> /etc/jug_info
