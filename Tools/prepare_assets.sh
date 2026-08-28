#!/bin/bash
set -euo pipefail

mkdir -p ImageBoardKeyboard/Resources

# The repository can contain the original archive as Images.b64 when binary upload
# is available. Decode it during CI/local preparation. This keeps the source tree
# text-only while preserving the original PNG bytes exactly.
if [ -f Images.b64 ]; then
  base64 --decode Images.b64 > ImageBoardKeyboard/Resources/Images.zip
  echo "Decoded Images.b64 -> ImageBoardKeyboard/Resources/Images.zip"
fi

# If a decoded archive is present, extract the original PNGs into Resources.
if [ -f ImageBoardKeyboard/Resources/Images.zip ]; then
  rm -rf ImageBoardKeyboard/Resources/Images
  mkdir -p ImageBoardKeyboard/Resources/Images
  unzip -oq ImageBoardKeyboard/Resources/Images.zip -d ImageBoardKeyboard/Resources/_unzipped
  if [ -d ImageBoardKeyboard/Resources/_unzipped/Images ]; then
    cp -f ImageBoardKeyboard/Resources/_unzipped/Images/*.png ImageBoardKeyboard/Resources/Images/ 2>/dev/null || true
  fi
  rm -rf ImageBoardKeyboard/Resources/_unzipped
fi

echo "Assets prepared. PNG count: $(find ImageBoardKeyboard/Resources/Images -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
