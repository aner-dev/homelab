#!/bin/bash
set -euo pipefail

# Usage: ./fetch-crds.sh <REPO_URL> <VERSION> <SOURCE_PATH> <TARGET_DIR>

REPO_URL="${1}"
VERSION="${2}"
SOURCE_PATH_REGEX="${3}" # The path where CRDs live in the repo
TARGET_DIR="${4}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

echo "Fetching CRDs for $REPO_URL ($VERSION)..."
git clone --depth 1 --branch "$VERSION" "$REPO_URL" "$WORK_DIR" >/dev/null 2>&1

# Find the directory based on the regex provided
SOURCE_PATH=$(find "$WORK_DIR" -type d -path "$SOURCE_PATH_REGEX" | head -n 1)

if [ -n "$SOURCE_PATH" ]; then
  mkdir -p "$TARGET_DIR"
  cp "$SOURCE_PATH"/*.yaml "$TARGET_DIR/"
  CRD_COUNT=$(find "$TARGET_DIR" -maxdepth 1 -type f -name "*.yaml" | wc -l)
  echo "Success: $CRD_COUNT CRDs moved to $TARGET_DIR"
else
  echo "Error: Could not locate directory matching $SOURCE_PATH_REGEX"
  exit 1
fi
