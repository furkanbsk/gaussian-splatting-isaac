# Troubleshooting Guide

This document records the issues encountered during the setup and training of the Gaussian Splatting pipeline and their solutions.

## 1. CUDA Version Mismatch
**Issue**: `RuntimeError: The detected CUDA version (12.1) mismatches the version that was used to compile PyTorch (11.8).`
**Solution**:
*   We patched `torch/utils/cpp_extension.py` to comment out the check.
*   We installed `cuda-toolkit=12.1` in the Conda environment to provide a compatible `nvcc`.

## 2. SIBR Viewer Compilation
**Issue A**: `fatal error: opencv2/ximgproc/edge_filter.hpp: No such file or directory`
**Solution**:
*   Installed `libopencv-contrib-dev`.
*   Configured CMake with `-DCMAKE_CXX_FLAGS="-I/usr/include/opencv4"`.

**Issue B**: `nvcc fatal : Unsupported gpu architecture 'compute_70'`
**Solution**:
*   The default CMake config targeted old GPUs.
*   We patched `extlibs/CudaRasterizer/CudaRasterizer/CMakeLists.txt` to use `CUDA_ARCHITECTURES "89"` (for RTX 4500 Ada).

**Issue C**: `CUDA driver version is insufficient for CUDA runtime version`
**Solution**:
*   The Conda environment had a newer CUDA runtime than the system driver supported.
*   We recompiled SIBR using the system's CUDA 12.6 toolkit (`/usr/local/cuda-12.6`) which matched the driver.

## 3. Out of Memory (OOM) during Training
**Issue**: Training process "Killed" by the OS.
**Cause**: 4K resolution images + depth maps exceeded 64GB RAM.
**Solution**:
*   Reduced training resolution using `--resolution 4` (downscales input by 4x).
*   Used `--data_device cpu` to keep dataset in RAM instead of VRAM (though RAM was the bottleneck here).

## 4. Depth Map Generation
**Issue**: `ModuleNotFoundError: No module named 'matplotlib'` or `'joblib'`.
**Solution**:
*   Installed missing dependencies: `pip install matplotlib joblib opencv-python`.

**Issue**: `FileNotFoundError` for checkpoints.
**Solution**:
*   Ran the script from within the `Depth-Anything-V2` directory or ensured relative paths were correct.

## 5. Path Duplication in Training
**Issue**: `can't open/read file: .../my_room_hq_dataset/my_room_hq_dataset/depths/...`
**Cause**: The training script automatically prepends the dataset path to the depth path argument.
**Solution**:
*   In `train_advanced.sh`, passed only the folder name `-d "depths"` instead of the full path.

## 6. Isaac Sim Extension Errors
**Issue**: `ModuleNotFoundError: No module named 'zmq'` when enabling `omni.gsplat.viewport`.
**Solution**:
*   The Isaac Sim python environment is missing `pyzmq`.
*   Fix: Run `/home/nvidia/isaacsim/python.sh -m pip install pyzmq`.

**Issue**: Viewport is "Blinking" or showing a flashing blank screen.
**Cause**: The extension is in "Idle" mode and waiting for an anchor object.
**Solution**:
1.  Create a Cube in Isaac Sim.
2.  Select it.
3.  Click the **"S"** button in the 3DGS Viewport window to link it.

**Issue**: "Permission Denied" when running `run_renderer.sh` (chmod error).
**Cause**: The socket folder `/tmp/omni-3dgs-extension` was owned by root from a previous run.
**Solution**:
*   Detailed in `isaac_sim_visualization.md`.
*   Fix: `sudo chown -R $USER:$USER /tmp/omni-3dgs-extension`.

**Issue**: "FileNotFoundError" in renderer logs.
**Cause**:
1.  The renderer script had a hardcoded path to a demo file.
2.  Use of symlinks: Docker cannot follow symlinks to files outside the mounted volume.
**Solution**:
*   We patched `main.py` to accept command-line arguments.
*   We replaced the symlink in `omni-3dgs-extension/assets` with a physical copy of the model folder.

**Issue**: Camera movement is too fast/slow or weird.
**Cause**: Scale mismatch between COLMAP units and Isaac Sim meters.
**Solution**:
*   Select the anchor **Cube** and change its **Scale**.
*   Try `100` (for speed up) or `0.01` (for slow down).
