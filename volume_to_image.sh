#!/bin/bash

DOCKERHUB_USER="ducleanh"
VOLUMES=("minio_data" "mysql_data" "esdata01" "redis_data")
WORKDIR="$(pwd)/volume_export"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

for VOLUME in "${VOLUMES[@]}"; do
    echo "Processing volume: $VOLUME"
    LOCAL_DIR="${WORKDIR}/${VOLUME}_data"
    IMAGE_TAG="${DOCKERHUB_USER}/${VOLUME}-data:latest"

    # Clear any previous data
    rm -rf "$LOCAL_DIR"
    mkdir -p "$LOCAL_DIR"

    # Use Docker container to copy data from volume to local folder
    docker run --rm \
        -v "${VOLUME}:/data" \
        -v "${LOCAL_DIR}:/backup" \
        alpine sh -c "cp -a /data/. /backup/"

    # Create Dockerfile
    cat > Dockerfile <<EOF
FROM alpine
COPY ${VOLUME}_data/ /data/
EOF

    # Build and push Docker image
    docker build -t "$IMAGE_TAG" .
    docker push "$IMAGE_TAG"

    # Clean up Dockerfile
    rm Dockerfile

    echo "--------------------------------------"
    echo "Backup image created and pushed: $IMAGE_TAG"
    echo "To restore:"
    echo "docker volume create $VOLUME"
    echo "docker run --rm -v $VOLUME:/target $IMAGE_TAG sh -c \"cp -a /data/. /target/\""
    echo "--------------------------------------"
done

echo "✅ All volumes have been exported to Docker images!"
