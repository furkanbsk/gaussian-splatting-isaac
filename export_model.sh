#!/bin/bash
# Usage: ./export_model.sh <model_dir> <output_name>

MODEL_DIR=$1
OUTPUT_NAME=$2

if [ -z "$MODEL_DIR" ]; then
    echo "Usage: ./export_model.sh <model_dir> [output_name]"
    exit 1
fi

if [ -z "$OUTPUT_NAME" ]; then
    OUTPUT_NAME="final_model.ply"
fi

# Find the latest iteration
ITERATION_DIR=$(find "$MODEL_DIR/point_cloud" -maxdepth 1 -type d -name "iteration_*" | sort -V | tail -n 1)

if [ -z "$ITERATION_DIR" ]; then
    echo "Error: No iteration directory found in $MODEL_DIR/point_cloud"
    exit 1
fi

SOURCE_PLY="$ITERATION_DIR/point_cloud.ply"

if [ ! -f "$SOURCE_PLY" ]; then
    echo "Error: point_cloud.ply not found in $ITERATION_DIR"
    exit 1
fi

echo "Found latest model at $SOURCE_PLY"
cp "$SOURCE_PLY" "$OUTPUT_NAME"
echo "Exported to $OUTPUT_NAME"
