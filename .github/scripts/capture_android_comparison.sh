#!/usr/bin/env bash
set -euo pipefail

readonly app_id='dev.designscale.design_scale_example'
readonly output_dir='artifacts/emulator'
readonly apk_dir='artifacts/apks'

mkdir -p "$output_dir"

adb wait-for-device
adb shell wm size 1600x2560
adb shell wm density 320
adb shell settings put system font_scale 1.0
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
adb shell input keyevent 82 || true

{
  echo 'Android emulator comparison environment'
  printf 'Android version: '
  adb shell getprop ro.build.version.release | tr -d '\r'
  printf 'API level: '
  adb shell getprop ro.build.version.sdk | tr -d '\r'
  adb shell wm size | tr -d '\r'
  adb shell wm density | tr -d '\r'
} > "$output_dir/device-info.txt"

capture() {
  local apk_path="$1"
  local output_name="$2"

  adb install -r "$apk_path"
  adb shell pm clear "$app_id" >/dev/null
  adb shell am force-stop "$app_id"
  adb logcat -c
  adb shell am start -W -n "$app_id/.MainActivity"

  local app_ready=false
  for _ in $(seq 1 20); do
    if adb shell pidof "$app_id" >/dev/null 2>&1; then
      app_ready=true
      break
    fi
    sleep 1
  done

  if [[ "$app_ready" != true ]]; then
    adb logcat -d > "$output_dir/${output_name}-logcat.txt"
    echo "The $output_name application process did not start." >&2
    return 1
  fi

  sleep 5
  adb logcat -d > "$output_dir/${output_name}-logcat.txt"
  adb exec-out screencap -p > "$output_dir/${output_name}.png"
  file "$output_dir/${output_name}.png"
}

capture "$apk_dir/before.apk" 'before'
capture "$apk_dir/after.apk" 'after'

sha256sum \
  "$output_dir/before.png" \
  "$output_dir/after.png" \
  > "$output_dir/checksums.txt"
