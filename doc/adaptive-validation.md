# Adaptive implementation validation status

Date: 2026-09-18
Base: `e0209872f7f1b0af9d2098910e11d247dc06ab18` (Phase 4 main)

## Performed

- Read the current main ref, public exports, configuration, and source contracts.
- Added an optional barrel without modifying the core/debug exports or renderer.
- Reviewed classification, fallback, original/virtual coordinate boundaries,
  navigator identity, and the scope's notification conditions.
- Authored model, widget, state-retention, environment, and example tests.
- Kept `.github/workflows`, package dependencies, and package version unchanged.
- Prepared one isolated feature commit; no merge, release, or publish.

## Not performed

| Gate | Status |
| --- | --- |
| Dart formatter | Not run: no Dart SDK in execution environment |
| Flutter analyzer | Not run: no Flutter SDK in execution environment |
| New and existing Flutter tests | Authored, NOT executed here |
| Minimum/stable SDK compatibility | Pending local execution |
| Example on emulator/simulator/device | Not run |
| Profile-mode benchmarks / memory measurements | Not run |
| GitHub Actions for this addition | Not triggered |

A Flutter SDK download was also unavailable from the execution environment.
Source review and Python sanity checks, where used, are not Dart compilation
or Flutter runtime evidence. Historical green CI on the base commit does not
validate the adaptive addition. This work must not be merged as "green" yet.

## Authored regression scenarios

- Exact default and custom breakpoint boundaries, invalid input, value equality.
- Configuration/builder fallback while retaining the measured window class.
- Original logical width versus physical/device pixels and virtual width.
- Window-class selection before scaling, including rotation and resized windows.
- Selected variant limits delegated to the existing core.
- Scope notifications and no additional selected-builder calls during idle pumps.
- Navigation stack/counter state across compact, medium, and expanded windows.
- Keyboard insets and text/accessibility values through the existing core.
- Explicit errors for missing scope, nested scaling, and partial viewports.
- Example navigation composition at three sizes and retained text-controller data.

## Next gate

Run `bash tool/validate_adaptive.sh` locally, review its output, and fix failures
locally before any push/PR. Repeat with the declared minimum and a stable SDK.
Only then consider one CI validation and a reviewable pull request.
