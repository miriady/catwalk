#!/usr/bin/env bash

# This script is used to build a multi-architecture container image
set -a
set -e
set -x

# Validate if required variables are set
if [[ -z "${REGISTRY}" ]]; then
  echo "REGISTRY not set"
  exit 1
fi
if [[ -z "${REPOSITORY}" ]]; then
  echo "REPOSITORY not set"
  exit 1
fi
if [[ -z "${IMAGE_NAME}" ]]; then
  echo "IMAGE_NAME not set"
  exit 1
fi
if [[ -z "${IMAGE_TAG}" ]]; then
  echo "IMAGE_TAG not set"
  echo "tagging 'unknown'"
  IMAGE_TAG='unknown'
else
  if [[ "${IMAGE_TAG}" =~ ^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$ ]]; then
    LATEST=1
  fi
fi
if [[ -z "${CONTEXT}" ]]; then
  echo "CONTEXT not set"
  echo "using '.'"
  CONTEXT='.'
fi

# Set manifest name
export MANIFEST_NAME="${IMAGE_NAME}"

# Create a multi-architecture manifest
buildah manifest create "${MANIFEST_NAME}"

# Build amd64 architecture container
if [[ -n "${LATEST}" ]]; then 
  buildah bud \
    --tag "${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --tag "${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:latest" \
    --manifest "${MANIFEST_NAME}" \
    --arch amd64 \
    ${FILE:+ --file "${FILE}"} "${CONTEXT}"
else
  buildah bud \
    --tag "${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --manifest "${MANIFEST_NAME}" \
    --arch amd64 \
    ${FILE:+ --file "${FILE}"} "${CONTEXT}"
fi

# Build arm64 architecture container
if [[ -n "${LATEST}" ]]; then 
  buildah bud \
    --tag "${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --tag "${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:latest" \
    --manifest "${MANIFEST_NAME}" \
    --arch arm64 \
    ${FILE:+ --file "${FILE}"} "${CONTEXT}"
else
  buildah bud \
    --tag "${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}" \
    --manifest "${MANIFEST_NAME}" \
    --arch arm64 \
    ${FILE:+ --file "${FILE}"} "${CONTEXT}"
fi

# Login into the container registry:
buildah login \
  --username "${ROBOT_USERNAME}" \
  --password "${ROBOT_PASSWORD}" \
  "${REGISTRY}"

# Push the full manifest, with both CPU Architectures, with IMAGE_TAG tag
buildah manifest push \
    --all \
    "${MANIFEST_NAME}" \
    "docker://${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:${IMAGE_TAG}"

if [[ -n "${LATEST}" ]]; then 
  # Push the full manifest, with both CPU Architectures, with latest tag
  buildah manifest push \
    --all \
    "${MANIFEST_NAME}" \
    "docker://${REGISTRY}/${REPOSITORY}/${IMAGE_NAME}:latest"
fi
