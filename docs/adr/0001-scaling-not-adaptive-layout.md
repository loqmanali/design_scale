# ADR 0001: Scaling is not adaptive layout

- Status: Accepted
- Date: 2026-09-17

## Context

Uniform scaling and adaptive composition solve different problems. Treating a scaled phone UI as a tablet layout produces poor information density and navigation choices.

## Decision

`design_scale` owns reference-space normalization only. It will not expose device-type decisions such as `isTablet` or automatic mobile/tablet/desktop widget branching.

Applications should use the virtual available space with Flutter layout primitives such as `LayoutBuilder` when composition must change.

## Consequences

The package stays small and predictable. Consumers remain responsible for product-specific adaptive layout decisions.
