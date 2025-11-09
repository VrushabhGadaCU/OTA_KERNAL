#!/bin/bash
# Script to build Yocto image for Raspberry Pi 4 with Wi-Fi enabled
# Author: Siddhant Jajoo, updated by ChatGPT (Wi-Fi + layer handling fixes)

set -e

echo "=== Initializing submodules ==="
git submodule init
git submodule sync
git submodule update

# Source environment
echo "=== Setting up build environment ==="
source poky/oe-init-build-env

# --- Configuration Lines ---
CONFLINE='MACHINE = "raspberrypi4-64"'
IMAGE='IMAGE_FSTYPES = "wic.bz2"'
MEMORY='GPU_MEM = "16"'
DISTRO_F='DISTRO_FEATURES:append = " wifi"'
IMAGE_F='IMAGE_FEATURES += "ssh-server-openssh"'
IMAGE_ADD='IMAGE_INSTALL:append = " linux-firmware-rpidistro-bcm43455 v4l-utils python3 ntp wpa-supplicant"'

CONF_FILE="conf/local.conf"

# --- Ensure local.conf exists ---
if [ ! -f "$CONF_FILE" ]; then
    echo "Error: local.conf not found. Make sure build environment is set correctly."
    exit 1
fi

# --- Clean up any duplicate or malformed IMAGE_INSTALL lines ---
sed -i '/IMAGE_INSTALL:append/d' "$CONF_FILE"

# --- Append or verify configuration lines ---
append_if_missing() {
    local line="$1"
    local file="$2"
    if ! grep -Fxq "$line" "$file"; then
        echo "Appending: $line"
        echo "$line" >> "$file"
    else
        echo "Already exists: $line"
    fi
}

append_if_missing "$CONFLINE" "$CONF_FILE"
append_if_missing "$IMAGE" "$CONF_FILE"
append_if_missing "$MEMORY" "$CONF_FILE"
append_if_missing "$DISTRO_F" "$CONF_FILE"
append_if_missing "$IMAGE_F" "$CONF_FILE"
append_if_missing "$IMAGE_ADD" "$CONF_FILE"

# --- Add Layers if Missing ---
add_layer_if_missing() {
    local layer_path="$1"
    local layer_name
    layer_name=$(basename "$layer_path")
    if ! bitbake-layers show-layers | grep -q "$layer_name"; then
        echo "Adding layer: $layer_path"
        bitbake-layers add-layer "$layer_path"
    else
        echo "Layer $layer_name already exists"
    fi
}

echo "=== Checking and adding layers ==="
add_layer_if_missing "../meta-openembedded/meta-oe"
add_layer_if_missing "../meta-openembedded/meta-python"
add_layer_if_missing "../meta-openembedded/meta-networking"
add_layer_if_missing "../meta-raspberrypi"

# --- Final Build ---
echo "=== Starting Yocto build for Raspberry Pi 4 ==="
bitbake core-image-base
