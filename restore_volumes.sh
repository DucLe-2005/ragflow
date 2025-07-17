#!/bin/bash

# Docker Hub username
DOCKERHUB_USER="ducleanh"

# List of volumes and their corresponding images
VOLUMES=("minio_data" "mysql_data" "esdata01" "redis_data")

for VOLUME in "${VOLUMES[@]}"; do
    echo "Restoring volume: $VOLUME"
    
    # Create the volume (does nothing if it already exists)
    docker volume create "$VOLUME"

    # Pull the backup image from Docker Hub (optional if already local)
    docker pull "${DOCKERHUB_USER}/${VOLUME}-data:latest"

    # Run a temporary container to restore data into the volume
    docker run --rm \
        -v "${VOLUME}:/target" \
        "${DOCKERHUB_USER}/${VOLUME}-data:latest" \
        sh -c "cp -a /data/. /target/"

    echo "✅ Restored $VOLUME"
    echo "------------------------------"
done

echo "🎉 All volumes have been restored!"
