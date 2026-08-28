# ImageBoard

Simeji-style custom iOS keyboard built around image-based keyboard assets.

## Build

GitHub Actions generates the Xcode project with XcodeGen and builds an unsigned iOS package automatically on every push to `main`.

The resulting `ImageBoard-unsigned.ipa` is uploaded as a workflow artifact.

## Project layout

- `ImageBoard/` — host iOS app
- `ImageBoardKeyboard/` — Keyboard Extension
- `ImageBoardKeyboard/Resources/Images/` — keyboard artwork
- `.github/workflows/build.yml` — automatic build
- `project.yml` — XcodeGen project definition

## Current stage

The extension has a functional UIKit keyboard with independent key hit targets. The next stage is mapping the supplied artwork precisely onto each key and implementing Japanese kana/flick input, keyboard modes, and theme selection.
