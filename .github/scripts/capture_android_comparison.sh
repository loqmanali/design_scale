#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
EXAMPLE_DIR="$ROOT_DIR/example"
OUTPUT_DIR="$ROOT_DIR/simulator_screenshots"
PACKAGE_NAME="dev.designscale.design_scale_example"
ACTIVITY_NAME="$PACKAGE_NAME/.MainActivity"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

cd "$EXAMPLE_DIR"

flutter create \
  --platforms=android \
  --org dev.designscale \
  --project-name design_scale_example \
  --no-pub \
  .
flutter pub get

adb wait-for-device
adb shell input keyevent KEYCODE_WAKEUP || true
adb shell wm dismiss-keyguard || true
adb shell wm size 720x1280
adb shell wm density 320
adb shell settings put system font_scale 1.0
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
adb shell cmd uimode night no || true
adb shell settings put system accelerometer_rotation 0
adb shell settings put system user_rotation 0

capture_variant() {
  local target="$1"
  local output_name="$2"

  echo "Building $target"
  flutter build apk --debug --no-pub --target="$target"

  adb install -r build/app/outputs/flutter-apk/app-debug.apk
  adb shell am force-stop "$PACKAGE_NAME" || true
  adb shell am start -S -W -n "$ACTIVITY_NAME"

  for _ in $(seq 1 20); do
    if adb shell pidof "$PACKAGE_NAME" >/dev/null 2>&1; then
      break
    fi
    sleep 1
  done

  sleep 8
  adb exec-out screencap -p > "$OUTPUT_DIR/$output_name"
  adb shell am force-stop "$PACKAGE_NAME" || true

  test -s "$OUTPUT_DIR/$output_name"
}

capture_variant lib/main_before.dart before.png
capture_variant lib/main_after.dart after.png

{
  echo "Android emulator comparison"
  echo "Model: $(adb shell getprop ro.product.model | tr -d '\r')"
  echo "API: $(adb shell getprop ro.build.version.sdk | tr -d '\r')"
  echo "$(adb shell wm size | tr -d '\r')"
  echo "$(adb shell wm density | tr -d '\r')"
  echo "Reference design: 375x812"
  echo "Before target: example/lib/main_before.dart"
  echo "After target: example/lib/main_after.dart"
} > "$OUTPUT_DIR/metadata.txt"

ls -lh "$OUTPUT_DIR"
