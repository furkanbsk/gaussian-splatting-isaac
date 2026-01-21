#!/bin/bash
# Usage: ./run_renderer.sh [model_path] [iteration]
#
# model_path: Relative to assets directory (default: my_room)
# iteration: Iteration number (default: 30000)

# Get script directory and source common functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/scripts/common.sh"

# Load user configuration
load_config

# Configuration (can be overridden in .gsconfig)
SOCKET_DIR="${GS_SOCKET_DIR:-/tmp/omni-3dgs-extension}"
CONTAINER_NAME="${DOCKER_CONTAINER_NAME:-vanillags-renderer}"
DOCKER_MOUNT_PATH="${DOCKER_MODEL_MOUNT:-/workspace/data}"

# Command-line arguments
MODEL_REL_PATH="${1:-my_room}"
ITERATION="${2:-30000}"

# Ensure the shared temporary directory exists
mkdir -p "$SOCKET_DIR"
chmod 777 "$SOCKET_DIR" 2>/dev/null || warn "Could not set permissions on $SOCKET_DIR"

# Construct path inside container
MODEL_PATH="$DOCKER_MOUNT_PATH/$MODEL_REL_PATH/point_cloud/iteration_$ITERATION/point_cloud.ply"

info "Starting VanillaGS Renderer inside Docker..."
info "Container: $CONTAINER_NAME"
info "Model path: $MODEL_PATH"
info "Socket directory: $SOCKET_DIR"

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    error "Docker container '$CONTAINER_NAME' is not running.
Please start it first with: docker compose up -d $CONTAINER_NAME"
fi

# Check if docker command is available
if ! command_exists docker; then
    error "Docker command not found. Please install Docker."
fi

# Execute renderer inside container
docker exec -it "$CONTAINER_NAME" bash -ic "python /src/main.py \"$MODEL_PATH\""
