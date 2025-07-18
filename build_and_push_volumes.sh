#!/bin/bash
set -euo pipefail

DOCKER_USER="ducleanh"
EXPORT_BASE="$PWD/volume_export"

for DIR in "$EXPORT_BASE"/*_data; do
  [ -d "$DIR" ] || continue

  FOLDER_NAME="$(basename "$DIR")"
  IMAGE_NAME="${DOCKER_USER}/${FOLDER_NAME,,}"  # lowercase

  echo "📦 Building image: $IMAGE_NAME"
  docker build -t "$IMAGE_NAME:latest" "$DIR"

  echo "🚀 Pushing image: $IMAGE_NAME"
  docker push "$IMAGE_NAME:latest"

  echo "✅ Done with: $IMAGE_NAME"
  echo "----------------------------"
done

echo "🎉 All images built and pushed!"
