# ADR-0005: Use a dedicated render viewport

- **Status:** Accepted
- **Date:** 2026-09-17

## Context

The foundation implementation used `FittedBox` and nested `SizedBox` widgets to prove the design-space and `MediaQuery` contracts. That implementation delegated layout, painting, hit testing, and semantics behavior to a general-purpose fitting primitive.

The package now needs an explicit rendering boundary whose behavior is owned and regression-tested by `design_scale`.

## Decision

Introduce an internal `DesignScaleViewport` / `RenderDesignScaleViewport` pair.

The render object:

1. lays out its child with tight `virtualSize` constraints;
2. reports a physical size equal to `virtualSize * scale`, constrained by its parent;
3. paints the child from the top-left origin with one uniform transform;
4. inverse-transforms pointer positions with `BoxHitTestResult.addWithPaintTransform`;
5. exposes the same transform through `applyPaintTransform`, allowing coordinate conversion and semantics traversal to follow the painted geometry;
6. scales intrinsic dimensions and baselines into parent coordinates;
7. remains private to the package implementation and is not exported from `design_scale.dart`.

`ScalePolicy` and `ScaleResult` remain the sole owners of scale calculation. The render object receives already-resolved values and contains no responsive or device-class policy.

## Consequences

### Positive

- Rendering behavior is explicit and testable.
- Layout, paint, hit testing, coordinate conversion, and semantics share one transform.
- The public API and domain contracts remain unchanged.
- The package no longer depends on `FittedBox` behavior for its core guarantee.
- Future clipping, alignment, and diagnostics work can evolve behind the same API.

### Trade-offs

- The package now owns low-level render-object correctness.
- Flutter rendering API changes require compatibility testing.
- Intended integration remains a bounded app-builder subtree; unusual parent constraints may constrain the requested physical size.

## Validation

Dedicated widget tests verify:

- virtual child layout size;
- local-to-global coordinate transformation;
- inverse pointer transformation during hit testing;
- live scale updates;
- invalid input rejection.
