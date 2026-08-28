#!/bin/bash
set -euo pipefail

mkdir -p ImageBoardKeyboard/Resources

if [ -f Images.b64 ]; then
  if base64 -D /dev/null >/dev/null 2>&1; then
    base64 -D Images.b64 > ImageBoardKeyboard/Resources/Images.zip
  else
    base64 --decode Images.b64 > ImageBoardKeyboard/Resources/Images.zip
  fi
  echo "Decoded Images.b64 -> ImageBoardKeyboard/Resources/Images.zip"
fi

if [ -f ImageBoardKeyboard/Resources/Images.zip ]; then
  rm -rf ImageBoardKeyboard/Resources/Images ImageBoardKeyboard/Resources/_unzipped
  mkdir -p ImageBoardKeyboard/Resources/Images ImageBoardKeyboard/Resources/_unzipped
  unzip -oq ImageBoardKeyboard/Resources/Images.zip -d ImageBoardKeyboard/Resources/_unzipped
  if [ -d ImageBoardKeyboard/Resources/_unzipped/Images ]; then
    cp -f ImageBoardKeyboard/Resources/_unzipped/Images/*.png ImageBoardKeyboard/Resources/Images/ 2>/dev/null || true
  fi
  rm -rf ImageBoardKeyboard/Resources/_unzipped
fi

echo "Assets prepared. PNG count: $(find ImageBoardKeyboard/Resources/Images -name '*.png' 2>/dev/null | wc -l | tr -d ' ')"
