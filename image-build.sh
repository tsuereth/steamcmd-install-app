#!/usr/bin/env sh

IMAGE_NAME=${IMAGE_NAME:-steamcmd-install-app}

BUILDTIME=$(date --utc +%Y%m%d%H%M%S)
BUILDTIME_TAG=buildtime-${BUILDTIME}
echo Tagging build: ${IMAGE_NAME}:${BUILDTIME_TAG}

IMAGE_DIR=image-context
docker build \
	--tag ${IMAGE_NAME}:buildtime-${BUILDTIME} \
	-f ${IMAGE_DIR}/Dockerfile ${IMAGE_DIR}

# The steamcmd version is recorded in a manifest file after steamcmd's self-updater runs.
# A helper script in the container image extracts that version number here.
STEAMCMD_VERSION=$(docker run --rm -it --entrypoint=/steamcmd-get-version.sh ${IMAGE_NAME}:buildtime-${BUILDTIME})
if [ -z "${STEAMCMD_VERSION}" ]; then
	echo Failed to determine steamcmd version
	exit 255
fi

VERSION_TAG=version-${STEAMCMD_VERSION}
echo Tagging build: ${IMAGE_NAME}:${VERSION_TAG}
docker tag ${IMAGE_NAME}:${BUILDTIME_TAG} ${IMAGE_NAME}:${VERSION_TAG}

if [ "${IMAGE_PUBLISH}" == "true" ]; then
	docker push ${IMAGE_NAME}:${BUILDTIME_TAG}
	docker push ${IMAGE_NAME}:${VERSION_TAG}
fi
