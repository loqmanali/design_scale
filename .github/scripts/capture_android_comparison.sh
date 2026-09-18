#!/usr/bin/env sh

set -eu

app_id='dev.designscale.design_scale_example'
output_dir='artifacts/emulator'

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
  adb shell getprop ro.build.version.release
  printf 'API level: '
  adb shell getprop ro.build.version.sdk
  adb shell wm size
  adb shell wm density
} > "$output_dir/device-info.txt"

capture() {
  apk_path="$1"
  output_name="$2"

  adb install -r "$apk_path"
  adb shell pm clear "$app_id" >/dev/null
  adb shell am force-stop "$app_id"
  adb shell am start -W -n "$app_id/.MainActivity"
  sleep 5
  adb exec-out screencap -p > "$output_dir/$output_name.png"
  file "$output_dir/$output_name.png"
}

capture 'artifacts/apks/before.apk' 'before'
capture 'artifacts/apks/after.apk' 'after'
