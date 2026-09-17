# Changelog

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
