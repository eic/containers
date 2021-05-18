#!/bin/bash

## Remove a specific docker tag from the eicweb registry

function print_the_help {
  echo "USAGE:    -i image -r reg_id tag "
  echo "ARGUMENTS:"
  echo "          -i,--image      Registry image name"
  echo "          -r,--reg-id     Registry image ID (integer number)"
  echo "          -h,--help       Print this message"
  echo "  positional              Tag to remove from registry"
  echo ""
  echo "  Remove a specific docker tag from the eicweb registry, if present on the
  registry."
  echo ""
  echo "EXAMPLE: ./cleanup_registry -i debian_base -r 66 unstable"
  exit
}

IMAGE=
REG_ID=
TAG=

while [ $# -gt 0 ]; do
  key=$1
  case $key in
    -i|--image)
      IMAGE=$2
      shift
      shift
      ;;
    -r|--reg-id)
      REG_ID=$2
      shift
      shift
      ;;
    -h|--help)
      print_the_help
      exit 0
      ;;
    -*)
      echo "ERROR: unknown flag: $key"
      echo "use --help for more info"
      exit 1
      ;;
    *)
      if [ ! -z ${TAG} ]; then
        echo "ERROR: multiple positional arguments specified"
        echo "use --help for more info"
        exit 1
      fi
      TAG=$1
      shift
      ;;
  esac
done

if [ -z $IMAGE ]; then
  echo "ERROR: no image name given, please use -i <IMAGE>"
  print_the_help
  exit 1
fi
if [ -z $REG_ID ]; then
  echo "ERROR: no image id given, please use -r <REG_ID>"
  print_the_help
  exit 1
fi
if [ -z $TAG ]; then
  echo "ERROR: no tag given, please specify a single tag (positional argument)"
  print_the_help
  exit 1
fi

echo "Cleaning up eicweb registry for ${IMAGE}:${TAG}"

IMAGE_EXISTS= 
docker manifest inspect \
  eicweb.phy.anl.gov:4567/containers/eic_container/${IMAGE}:${TAG} \
    > /dev/null \
  && IMAGE_EXISTS=1 \
  || echo "Image not found, no cleanup needed"

if [ ! -z ${IMAGE_EXISTS} ]; then
  curl --request DELETE --header "PRIVATE-TOKEN: ${REG_CLEANUP_TOKEN}" \
    ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/registry/repositories/${REG_ID}/tags/${TAG} \
  && echo "Image removed" \
  || echo "Error trying to remove image"
fi
