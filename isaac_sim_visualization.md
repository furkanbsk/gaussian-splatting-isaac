# Omniverse 3D Gaussian Splatting Extension Setup

This guide explains how to set up the `omni-3dgs-extension` to visualize your trained models in Isaac Sim.

## 1. Add Extension to Isaac Sim

1.  Open **Isaac Sim**.
2.  Go to **Window** -> **Extensions**.
3.  Click the **Gear Icon** (Settings) in the top right of the Extensions window.
4.  Under **Extension Search Paths**, click the **+** button and add this path:
    ```
    /home/nvidia/Desktop/Main_Workspace/3D_reconstruction/omni-3dgs-extension/extension/exts
    ```
5.  Close the Settings window.
6.  In the Extensions search bar, type **"Gaussian"**.
7.  You should see **"Omniverse 3D Gaussian Splatting Extension"** (omni.gsplat.viewport).
8.  Toggle the switch to **ENABLE** it.

## 2. Prepare the Backend Renderer

The extension requires a backend renderer running in Docker.

1.  **Build the Docker Image**:
    Open a terminal and run:
    ```bash
    cd /home/nvidia/Desktop/Main_Workspace/3D_reconstruction/omni-3dgs-extension
    docker compose build vanillags-renderer
    ```

2.  **Start the Renderer Container**:
    ```bash
    docker compose up -d vanillags-renderer
    ```
    (The `-d` flag runs it in the background).

3.  **Run the Renderer Server**:
    The container is running, but we need to start the actual program.
    ```bash
    ./run_renderer.sh
    ```
    *   This will hang and show logs. This is normal! It means the server is running.

## 3. Visualize Your Model

1.  We have already linked your trained model to the extension's assets folder:
    *   **Source**: `my_room_advanced`
    *   **Link**: `omni-3dgs-extension/assets/my_room`


2.  In Isaac Sim, with the extension enabled:
    *   **Open the Viewport**: Go to **Window** -> **3DGS Viewport**.
    *   **Stop the Blinking**: The "blinking" or flashing screen means it's waiting for you to select an anchor object.
    *   **Create an Anchor**:
        1.  Go to **Create** -> **Shape** -> **Cube**. (This cube will represent your room's center).
        2.  Select the **Cube** in the Stage panel.
    *   **Link it**:
        1.  In the **3DGS Viewport** window, look for the **"3DGS Mesh"** field.
        2.  Click the **"S"** button next to it.
        3.  The path (e.g., `/World/Cube`) should appear in the text box.
    *   **Result**: The renderer should now stop blinking and show your Gaussian Splat model! You can move the Cube to move the model.

## Troubleshooting

*   **Renderer Connection**: If the viewer is grayed out, ensure the `docker compose up` command is running and there are no errors in the terminal.
*   **Docker Permissions**: If you get permission errors with docker, try running with `sudo` or ensure your user is in the `docker` group.
