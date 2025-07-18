#!/bin/bash
set -e

# Docker Hub images mapping
declare -A BACKUP_IMAGES=(
  ["docker_esdata01"]="ducleanh/esdata01_data:latest"
  ["docker_minio_data"]="ducleanh/minio_data_data:latest"
  ["docker_mysql_data"]="ducleanh/mysql_data_data:latest"
  ["docker_redis_data"]="ducleanh/redis_data-data:latest"
)

echo "🔄 Restoring RAGFlow volumes from backup images..."

for VOLUME in "${!BACKUP_IMAGES[@]}"; do
  IMAGE="${BACKUP_IMAGES[$VOLUME]}"
  TMP_CONT="tmp_restore_${VOLUME}"

  echo "⏬ Pulling $IMAGE..."
  docker pull "$IMAGE"

  echo "🐢 Creating temp container from $IMAGE..."
  docker create --name "$TMP_CONT" "$IMAGE" > /dev/null

  echo "📤 Copying data into volume $VOLUME..."
  docker run --rm \
    --volumes-from "$TMP_CONT" \
    -v "${VOLUME}:/target" \
    alpine \
      sh -c "cp -a /data/. /target/"

  echo "🗑 Removing temporary container..."
  docker rm "$TMP_CONT" > /dev/null

done