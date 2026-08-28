#!/bin/bash
set -euo pipefail

RESOURCE_DIR="ImageBoardKeyboard/Resources"
mkdir -p "$RESOURCE_DIR"

# The source ZIP is stored in the repository at ImageBoard/Assets/Images.zip.
# Copy it into the keyboard target's resources before extraction.
SOURCE_ZIP="ImageBoard/Assets/Images.zip"
TARGET_ZIP="$RESOURCE_DIR/Images.zip"

if [ -f "$SOURCE_ZIP" ]; then
  cp -f "$SOURCE_ZIP" "$TARGET_ZIP"
  echo "Using uploaded $SOURCE_ZIP"
elif [ -f "Images.b64" ]; then
  if base64 -D /dev/null >/dev/null 2>&1; then
    base64 -D Images.b64 > "$TARGET_ZIP"
  else
    base64 --decode Images.b64 > "$TARGET_ZIP"
  fi
  echo "Decoded Images.b64 -> $TARGET_ZIP"
fi

if [ -f "$TARGET_ZIP" ]; then
  rm -rf "$RESOURCE_DIR/Images" "$RESOURCE_DIR/_unzipped"
  mkdir -p "$RESOURCE_DIR/Images" "$RESOURCE_DIR/_unzipped"
  unzip -oq "$TARGET_ZIP" -d "$RESOURCE_DIR/_unzipped"

  # The supplied archive contains an Images/ directory with the PNG assets.
  find "$RESOURCE_DIR/_unzipped" -type f -iname '*.png' -exec cp -f {} "$RESOURCE_DIR/Images/" \;
  rm -rf "$RESOURCE_DIR/_unzipped"
fi

PNG_COUNT=$(find "$RESOURCE_DIR/Images" -type f -iname '*.png' 2>/dev/null | wc -l | tr -d ' ')
echo "Assets prepared. PNG count: $PNG_COUNT"

# Fail the build rather than silently producing a keyboard without its artwork.
test "$PNG_COUNT" -gt 0
