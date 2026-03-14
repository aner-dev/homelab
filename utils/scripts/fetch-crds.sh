#!/bin/bash
set -euo pipefail

MANIFEST="infrastructure/crds/versions.yaml"

if ! command -v yq &>/dev/null; then
  echo "Error: yq is not installed."
  exit 1
fi

for app in $(yq eval '.applications | keys | .[]' "$MANIFEST"); do
  REPO=$(yq eval ".applications.$app.repo" "$MANIFEST")
  VER=$(yq eval ".applications.$app.version" "$MANIFEST")
  SRC_PATH=$(yq eval ".applications.$app.source_path" "$MANIFEST")
  DST_DIR=$(yq eval ".applications.$app.target_dir" "$MANIFEST")

  echo "--- Processing $app ($VER) ---"

  # 1. Skip if already synced
  if [ -f "$DST_DIR/.version" ] && [ "$(cat "$DST_DIR/.version")" == "$VER" ]; then
    echo "$app is already at version $VER. Skipping."
    continue
  fi

  # 2. Setup environment
  WORK_DIR=$(mktemp -d)
  trap 'rm -rf "$WORK_DIR"' EXIT
  git clone --depth 1 --branch "$VER" "$REPO" "$WORK_DIR" >/dev/null 2>&1

  CLONE_PATH="$WORK_DIR/$SRC_PATH"
  mkdir -p "$DST_DIR"

  # 3. Centralized Copy Logic
  if [ -d "$CLONE_PATH" ]; then
    cp "$CLONE_PATH"/*.yaml "$DST_DIR/"
  elif [ -f "$CLONE_PATH" ]; then
    cp "$CLONE_PATH" "$DST_DIR/$(basename "$CLONE_PATH")"
  else
    echo "Error: $CLONE_PATH does not exist!"
    exit 1
  fi

  echo "$VER" >"$DST_DIR/.version"
  echo "Successfully updated $app CRDs in $DST_DIR"
done
