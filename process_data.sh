#!/bin/bash
# Usage: ./process_data.sh <video_file> <output_dir>

VIDEO=$1
OUTPUT_DIR=$2

if [ -z "$VIDEO" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: ./process_data.sh <video_file> <output_dir>"
    exit 1
fi

mkdir -p "$OUTPUT_DIR/input"

echo "Extracting frames from $VIDEO to $OUTPUT_DIR/input..."
# Extract frames at 3 fps for higher quality overlap
ffmpeg -i "$VIDEO" -qscale:v 1 -r 3 "$OUTPUT_DIR/input/%04d.jpg"

echo "Running COLMAP conversion..."
# Ensure we use the correct environment
eval "$(conda shell.bash hook)"
conda activate gs_env

# Run convert.py
python gaussian-splatting/convert.py -s "$OUTPUT_DIR"
