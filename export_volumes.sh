#!/bin/bash
set -e

VOLUMES=(
  "docker_mysql_data"
  "docker_minio_data"
  "docker_redis_data"
  "docker_esdata01"
)
EXPORT_BASE="$PWD/volume_export"
mkdir -p "$EXPORT_BASE"

for VOLUME in "${VOLUMES[@]}"; do
  NAME="${VOLUME/docker_/}"
  FOLDER="${NAME}_data"
  EXPORT_PATH="$EXPORT_BASE/$FOLDER"
  CONTAINER="temp_copy_$NAME"

  echo "📦 Exporting $VOLUME → $EXPORT_PATH"
  mkdir -p "$EXPORT_PATH/data"

  docker run -d --name "$CONTAINER" -v "$VOLUME:/data" alpine tail -f /dev/null
  docker cp "$CONTAINER:/data/." "$EXPORT_PATH/data"
  docker rm -f "$CONTAINER" &> /dev/null

  cat > "$EXPORT_PATH/Dockerfile" <<EOF
FROM alpine
COPY ./data /data
EOF

  # Build dockerignore
  IGN="$EXPORT_PATH/.dockerignore"
  echo -e "*\n!data/" > "$IGN"

  if [[ "$NAME" == "mysql_data" ]]; then
    cat >> "$IGN" <<EOL
data/mysql.sock
data/ibtmp1
data/ib_buffer_pool
data/#ib_*
data/*.pid
data/*.err
EOL
  elif [[ "$NAME" == "esdata01" ]]; then
    cat >> "$IGN" <<EOL
data/node.lock
data/nodes
data/snapshot_cache
EOL
  fi

  echo "✅ Done: $VOLUME"
done

echo "🎉 Export complete at $EXPORT_BASE"
