#!/bin/bash

## Generic script to execute docker push from the input tag to all export tags
## on both dockerhub and eicweb if set

function print_the_help {
  echo "USAGE:    -i image -l input_tag export_tag [export_tag2 ...]"
  echo "ARGUMENTS:"
  echo "          -i,--image      Input image name (e.g., eic_base)"
  echo "          -l,--label      Input tag (eg., v3.0.0)"
  echo "          -t,--time       Time interval (in seconds) between attempts"
  echo "                          (doubled each time), default: 5"
  echo "          -n,--n-attempts Number of attempts, default: 5"
  echo "          -h,--help       Print this message"
  echo "          --eicweb        Publish to $CI_REGISTRY only"
  echo "          --dockerhub     Publish to DH only"
  echo "  positional              At least one export tag (e.g., v3.0-stable)"
  echo ""
  echo "  Execute docker push from image:input_tag to REGISTRY/image:export_tag for"
  echo "  for all export tags. Will push to $CI_REGISTRY, and optionally also to"
  echo "  Dockerhub if the DH_PUSH environment variable is set"
  echo ""
  echo "EXAMPLE: ./docker_push.sh -i eic_base -l 3.0.0 3.0.0 3.0-stable"
  exit
}

IMAGE=
INPUT_TAG=
EXPORT_TAGS=()
NTRIES=5
TIME=5
DO_DH=${DH_PUSH}
DO_EICWEB=1

while [ $# -gt 0 ]; do
  key=$1
  case $key in
    -i|--image)
      IMAGE=$2
      shift
      shift
      ;;
    -l|--label)
      INPUT_TAG=$2
      shift
      shift
      ;;
    -t|--time)
      TIME=$2
      shift
      shift
      ;;
    -n|--n-attempts)
      NTRIES=$2
      shift
      shift
      ;;
    --eicweb)
      DO_DH=0
      shift
      ;;
    --dockerhub)
      DO_EICWEB=0
      DO_DH=1
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
      EXPORT_TAGS+=("$1")
      shift
      ;;
  esac
done

if [ -z $IMAGE ]; then
  echo "ERROR: no image name given, please use -i <IMAGE>"
  print_the_help
  exit 1
fi
if [ -z $INPUT_TAG ]; then
  echo "ERROR: no input_Tag given, please use -t <INPUT_TAG>"
  print_the_help
  exit 1
fi
if [ ${#EXPORT_TAGS[@]} -eq 0 ]; then
  echo "ERROR: need at least one export tag (positional argument)"
  print_the_help
  exit 1
fi

function retry_push () {
  INPUT=$1
  DESTINATION=$2
  time=$TIME
  ntries=$NTRIES
  echo "Pushing ${INPUT} to ${DESTINATION}"
  if [ ${INPUT} != ${DESTINATION} ]; then
    echo docker tag ${INPUT} ${DESTINATION}
    docker tag ${INPUT} ${DESTINATION}
  fi
  while [ $ntries != 0 ]; do
    echo docker push ${DESTINATION} 
    docker push ${DESTINATION} && break \
      || echo "Docker push failed, retrying in $time seconds..."
    sleep ${time}s
    time=$((time * 2))
    ntries=$((ntries - 1))
  done
  if [ ${INPUT} != ${DESTINATION} ]; then
    echo docker rmi ${DESTINATION}
    docker rmi ${DESTINATION}
  fi
  if [ $ntries = 0 ]; then
    echo "Failed to push $INPUT to $DESTINATION"
    exit 1
  fi
}

#echo "IMAGE: ${IMAGE}"
#echo "INPUT_TAG: ${INPUT_TAG}"
#echo "EXPORT_TAGS: ${EXPORT_TAGS}"
#echo "DH_PUSH: ${DH_PUSH}"
#echo "DO_DH: ${DO_DH}"
#echo "DO_EICWEB: ${DO_EICWEB}"

export INPUT=$CI_REGISTRY_IMAGE/${IMAGE}:${INPUT_TAG}
for TAG in ${EXPORT_TAGS[@]}; do
  if [ ${DO_EICWEB} != 0 ]; then
    retry_push $INPUT $CI_REGISTRY_IMAGE/${IMAGE}:${TAG}
  fi
  if [ ${DO_DH} != 0 ]; then
    retry_push $INPUT $DH_REGISTRY/${IMAGE}:${TAG}
  fi
done
