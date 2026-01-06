#!/bin/bash
# Usage: ./run_renderer.sh

# Ensure the shared temporary directory exists
mkdir -p /tmp/omni-3dgs-extension
chmod 777 /tmp/omni-3dgs-extension

# Path to the mounted model inside the container
MODEL_PATH="/workspace/data/my_room/point_cloud/iteration_30000/point_cloud.ply"

echo "Starting VanillaGS Renderer inside Docker..."
docker exec -it vanillags-renderer bash -ic "python /src/main.py \"$MODEL_PATH\""
