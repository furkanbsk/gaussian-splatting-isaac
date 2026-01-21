#!/bin/bash
# Usage: ./process_data.sh <video_file> <output_dir>

# Get script directory and source common functions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/scripts/common.sh"

# Load user configuration
load_config

VIDEO=$1
OUTPUT_DIR=$2

if [ -z "$VIDEO" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: ./process_data.sh <video_file> <output_dir>"
    exit 1
fi

if [ ! -f "$VIDEO" ]; then
    error "Video file '$VIDEO' not found."
fi

mkdir -p "$OUTPUT_DIR/input"

info "Extracting frames from $VIDEO to $OUTPUT_DIR/input..."
# Extract frames at 3 fps for higher quality overlap
if ! command_exists ffmpeg; then
    error "ffmpeg not found. Please install ffmpeg."
fi

ffmpeg -i "$VIDEO" -qscale:v 1 -r 3 "$OUTPUT_DIR/input/%04d.jpg"

info "Running COLMAP conversion..."

# Ensure conda environment (if needed)
ensure_conda_env "${GS_CONDA_ENV:-gs_env}"

# Get Python interpreter
PYTHON=$(get_python_interpreter)
info "Using Python: $PYTHON"

# Get repo root and resolve convert.py path
REPO_ROOT=$(get_repo_root)
CONVERT_SCRIPT="$REPO_ROOT/convert.py"

if [ ! -f "$CONVERT_SCRIPT" ]; then
    error "Convert script not found at: $CONVERT_SCRIPT"
fi

# Run convert.py
$PYTHON "$CONVERT_SCRIPT" -s "$OUTPUT_DIR"

info "Data processing complete!"
info "Dataset ready at: $OUTPUT_DIR"
