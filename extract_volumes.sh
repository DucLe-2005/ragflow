#!/bin/bash

# List of Docker volumes
VOLUMES=(
  docker_minio_data
  docker_mysql_data
  docker_redis_data
  docker_esdata01
)

# Target directory for temporary volume extraction
STAGING_DIR="ragflow_volumes_tmp"

# Create the staging directory
mkdir -p "$STAGING_DIR"

# Loop over each volume and extract its contents & archive individually
for VOLUME_NAME in "${VOLUMES[@]}"; do
  VOLUME_STAGING="$STAGING_DIR/$VOLUME_NAME"
  ARCHIVE_NAME="$VOLUME_NAME.tar.gz"

  echo "Extracting volume: $VOLUME_NAME → $VOLUME_STAGING"
  mkdir -p "$VOLUME_STAGING"

  docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    -v "$(pwd)/$VOLUME_STAGING:/backup" \
    busybox \
    sh -c "cp -a /data/. /backup/"

  echo "Creating archive: $ARCHIVE_NAME in project root"
  tar czf "./$ARCHIVE_NAME" -C "$VOLUME_STAGING" .

  # Clean up that volume's staging directory
  rm -rf "$VOLUME_STAGING"
done

# Optionally clean up the main staging dir if empty
rmdir "$STAGING_DIR" 2>/dev/null || true

echo "✅ Done! Archives created in project root: ${VOLUMES[@]/%/.tar.gz}"