#!/bin/bash
set -euo pipefail

# 1. Setup a safe workspace
REPO_URL="https://github.com/cilium/cilium"
VERSION="v1.19.1"
WORK_DIR=$(mktemp -d)
TARGET_DIR="./infrastructure/crds/cilium/manifests"

# Ensure cleanup even if the script fails
trap 'rm -rf "$WORK_DIR"' EXIT

echo "Cloning $REPO_URL at $VERSION..."
git clone --depth 1 --branch "$VERSION" "$REPO_URL" "$WORK_DIR"

# 2. Senior Discovery: Instead of just 'fd', we target the known API paths
# but use 'find' to grab all .yaml files in those specific structural locations.
echo "Locating CRDs..."
# This finds the directory you identified earlier
SOURCE_PATH=$(find "$WORK_DIR" -type d -path "*/pkg/k8s/apis/cilium.io/client/crds/v2" | head -n 1)

if [ -n "$SOURCE_PATH" ]; then
  mkdir -p "$TARGET_DIR"
  cp "$SOURCE_PATH"/*.yaml "$TARGET_DIR/"
  # This counts only files in the target directory safely
  CRD_COUNT=$(find "$TARGET_DIR" -maxdepth 1 -type f -name "*.yaml" | wc -l)
  echo "Success: Moved $CRD_COUNT CRDs."
else
  echo "Error: Could not locate CRD directory!"
  exit 1
fi

echo "------------------------------------------------"
echo "Mission accomplished!"
echo "CRDs successfully synchronized to: $TARGET_DIR"
echo "Verify them with: ls -1 $TARGET_DIR"
echo "------------------------------------------------"
