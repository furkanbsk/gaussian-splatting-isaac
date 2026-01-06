#!/bin/bash
# Usage: ./run_sibr.sh [model_path]

MODEL_PATH=$1

if [ -z "$MODEL_PATH" ]; then
    MODEL_PATH="my_room_hq_model"
fi

if [ ! -d "$MODEL_PATH" ]; then
    echo "Error: Model directory '$MODEL_PATH' not found."
    echo "Usage: ./run_sibr.sh <model_dir>"
    exit 1
fi

echo "Launching SIBR Viewer for $MODEL_PATH..."
./gaussian-splatting/SIBR_viewers/install/bin/SIBR_gaussianViewer_app -m "$MODEL_PATH"
