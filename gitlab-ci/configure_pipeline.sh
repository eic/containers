#!/bin/bash

## Configure a CI pipeline based on a template file (first and only
## argument to this script).
TEMPLATE_FILE=$1
OUTPUT_FILE=`basename ${TEMPLATE_FILE} .in`

echo "Configuring pipeline script: ${TEMPLATE_FILE}"
echo "Output will be written to: ${OUTPUT_FILE}"

VERSION=`head -n1 VERSION`
STABLE="${VERSION%.*}-stable"

## Figure out which scenario we are running:
##  - master
##  - stable
##  - tag
##  - unstable (default)
TARGET=""
TAG=""
PUBLISH=""
if [ "$CI_COMMIT_BRANCH" = "master" ]; then
  TARGET="stable"
	TAG="latest"
	PUBLISH="publish-latest publish-stable"
elif [ "$CI_COMMIT_TAG" = "v${VERSION}" ]; then
  TARGET="stable"
	TAG=$VERSION
	PUBLISH="publish-version"
elif [ "$CI_COMMIT_BRANCH" = "v${STABLE}" ]; then
  TARGET="stable"
	TAG=${STABLE}
	PUBLISH="publish-stable"
else
  TARGET="unstable"
	TAG="unstable"
	PUBLISH="publish-unstable"
fi

TARGET_BUILDER=$TARGET
TARGET_RELEASE=$TARGET

if [ ! -f .ci_env/buider-nc ]; then
  TARGET_BUILDER="${TARGET_BUILDER}-cached"
fi
if [ ! -f .ci_env/release-nc ]; then
  TARGET_BUILDER="${TARGET_RELEASE}-cached"
fi

sed "s/@TAG@/$TAG/g" $TEMPLATE_FILE | \
  sed "s/@TARGET_BUILDER@/$TARGET_BUILDER/g" | \
	sed "s/@TARGET_RELEASE@/$TARGET_RELEASE/g" | \
	sed "s/@PUBLISH@/$PUBLISH/g" > ${OUTPUT_FILE}

echo "Done"
