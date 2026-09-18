#!/usr/bin/env bash
# Local validation only: no GitHub API calls, pushes, or workflow triggers.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
command -v flutter >/dev/null || { echo "Flutter SDK is required." >&2; exit 127; }
command -v dart >/dev/null || { echo "Dart SDK is required." >&2; exit 127; }
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test example benchmark
flutter analyze
flutter test --coverage
(
  cd example
  flutter pub get
  flutter analyze
  flutter test
)
flutter pub publish --dry-run
