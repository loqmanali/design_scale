# Changelog

## Unreleased — optional adaptive composition

- Add the opt-in `design_scale_adaptive.dart` library without changing core exports.
- Select window classes from original logical width before scaling.
- Add configurable breakpoints, variant/layout fallback, scope, and typed values.
- Keep one navigator child across reference-size changes; shared layout state remains application-owned.
- Add an adaptive example and authored model/widget/example regression tests.
- Document integration boundaries, experimental API, and pending Flutter validation.
- No version bump, workflow change, CI execution, or publication in this change.

## 0.1.0-rc.1

- Freeze the release-candidate core public API.
- Add a secondary `design_scale_debug.dart` library with runtime diagnostics and a debug-only overlay.
- Add a runnable example demonstrating app-builder integration, normal Flutter dimensions, adaptive composition, keyboard behavior, and diagnostics.
- Add public API and migration documentation.
- Add a non-gating viewport performance benchmark harness.
- Strengthen CI with formatting, example validation, coverage execution, and pub publish dry-run checks.

## 0.1.0-dev.3

- Transform fold, hinge, and cutout bounds into virtual design coordinates.
- Transform gesture thresholds so physical interaction distances remain stable.
- Add explicit semantics-geometry coverage.
- Add keyboard, foldable, resize, rotation, split-screen, and viewport-matrix tests.
- Add deterministic golden coverage for portrait, large portrait, split-width, and landscape viewports.
- Verify the full suite on Flutter 3.19.0 and the current stable channel.
- Document the rounded display-corner limitation while Flutter 3.19 is supported.

## 0.1.0-dev.2

- Replace the internal `FittedBox` implementation with a dedicated render viewport.
- Keep layout, paint, hit testing, coordinate conversion, and semantics on one uniform transform.
- Add rendering regression tests for virtual layout, transformed coordinates, pointer hit testing, and live scale updates.
- Add ADR-0005 documenting the dedicated render-viewport decision.

## 0.1.0-dev.1

- Establish the Architecture Kata foundation.
- Add a pure policy-driven scale engine.
- Add `ContainScalePolicy` as the default uniform scaling strategy.
- Add instance-scoped scale limits with no global mutable configuration.
- Add spatial `MediaQuery` transformation while preserving accessibility and device-pixel-ratio data.
- Add `DesignScaleScope` for runtime diagnostics.
- Add initial unit, widget, and CI coverage.
