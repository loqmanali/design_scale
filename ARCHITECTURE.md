# design_scale Architecture

## 1. Problem statement

Flutter applications are commonly authored from a reference design frame. Teams often compensate for varying screens by scattering width, height, radius, and font-size extensions through presentation code. `design_scale` instead creates a stable virtual design space and uniformly maps it to the current Flutter viewport.

The package is a **design-space scaling engine**, not an adaptive-layout framework.

## 2. Architectural drivers

In priority order:

1. **Correctness** — the same inputs produce the same scale.
2. **Predictability** — scaling behavior must be explicit and policy-driven.
3. **Accessibility preservation** — do not override `TextScaler`, accessibility flags, or device pixel ratio.
4. **Window adaptability** — react to the current Flutter `MediaQuery`, including resize, rotation, split-screen, keyboard, and foldable geometry.
5. **Testability** — scale math and geometry conversion are pure and testable without pumping widgets.
6. **Extensibility** — new scale policies can be added without changing the rendering API.
7. **Performance** — scale resolution is O(1) and no external runtime dependency is required.
8. **Simplicity** — the default public API remains small.
9. **Release stability** — implementation details must remain replaceable behind a deliberate public contract.

## 3. Invariants

- Use one uniform scale factor; never independently stretch x and y.
- Configuration is instance-scoped and immutable from the package perspective.
- No global mutable reference size.
- Never rewrite `devicePixelRatio`.
- Never rewrite `TextScaler` or accessibility preferences.
- Scale math lives outside the widget/rendering layer.
- `design_scale` never decides whether the application should use mobile, tablet, or desktop composition.
- Integration happens below `MaterialApp`/`CupertinoApp` through their builder callback.
- Layout, paint, hit testing, coordinate conversion, and semantics use the same transform.
- Every logical-pixel position or distance exposed below `DesignScale` belongs to the virtual coordinate system.
- Rendering, MediaQuery adapters, geometry transformers, and diagnostics implementation remain replaceable details.

## 4. Runtime flow

```text
Flutter MediaQuery
       |
       v
   ScaleInput  <---- reference size / policy / limits
       |
       v
   ScalePolicy
       |
       v
   ScaleResult
      / \
     v   v
virtual   RenderDesignScaleViewport
MediaQuery     |
transform      | layout / paint / hit test / semantics
     \         /
      v       v
  application subtree
```

## 5. Layers

```text
lib/
  design_scale.dart        Stable core public barrel
  design_scale_debug.dart  Optional secondary debug barrel

lib/src/
  api/          Public widget and inherited scope
  config/       Public immutable configuration values
  domain/       Pure inputs, results, limits, policy contract
  policies/     Scale-policy implementations
  media_query/  Window geometry and MediaQuery adapters
  rendering/    Internal render viewport and coordinate mapping
  diagnostics/  Optional debug snapshot and overlay
```

Dependency direction is toward the domain contracts. Rendering and Flutter adapters may depend on domain types; domain math does not depend on widget state or app lifecycle. The core barrel does not export rendering, MediaQuery, geometry, or diagnostics implementation types.

## 6. Default scale policy

`ContainScalePolicy` computes:

```text
widthScale  = viewportWidth  / referenceWidth
heightScale = viewportHeight / referenceHeight
scale       = min(widthScale, heightScale)
virtualSize = viewportSize / scale
```

This keeps the scale uniform and exposes any extra axis as virtual layout space instead of distorting the design.

## 7. MediaQuery and window-geometry contract

Spatial values are transformed into virtual design-space coordinates:

- `size`
- `padding`
- `viewPadding`
- `viewInsets`
- `systemGestureInsets`
- every `displayFeatures.bounds` rectangle
- `gestureSettings.touchSlop`

Display-feature `type` and `state` are preserved. Non-spatial platform and accessibility values remain unchanged, including device pixel ratio, text scaling, brightness, high contrast, navigation mode, and accessibility flags.

`displayCornerRadii` is not transformed while Flutter 3.19 remains the minimum supported version because that release does not expose the property on `MediaQueryData`. This limitation is explicit rather than hidden behind dynamic version checks.

## 8. Rendering contract

`DesignScaleViewport` is an internal `SingleChildRenderObjectWidget` backed by `RenderDesignScaleViewport`.

The render object:

- lays out the child with tight virtual design-space constraints;
- occupies the corresponding physical size;
- paints with one top-left uniform scale transform;
- inverse-transforms pointer positions for hit testing;
- publishes the same transform through `applyPaintTransform` for coordinate conversion and semantics;
- scales intrinsic dimensions and baselines into parent coordinates.

The rendering implementation is not exported. Consumers depend only on the documented core public API.

## 9. Public API and diagnostics boundary

The release-candidate core surface is documented in `docs/public-api.md`. Debug diagnostics are intentionally exported from `package:design_scale/design_scale_debug.dart` rather than the core barrel.

This allows diagnostic presentation to evolve without forcing applications that only need scaling to depend on debug-specific UI. `DesignScaleDebugOverlay` is inactive outside debug builds.

## 10. Verification strategy

- **Unit:** policy math, limits, invalid configuration, and window-geometry conversion.
- **Widget:** transformed `MediaQuery`, accessibility preservation, keyboard, foldable, resize, rotation, split-screen, diagnostics, and public API scenarios.
- **Rendering:** virtual layout, paint transform, hit testing, coordinate conversion, semantics geometry, and runtime updates.
- **Golden:** deterministic reference, large portrait, split-width, and landscape output.
- **Example:** a separate package is analyzed and tested against the local package dependency.
- **Compatibility:** the full analyzer and test suite run on Flutter 3.19.0 and the current stable channel.
- **Publishing:** CI performs a pub publish dry run before merge.
- **Performance:** a controlled, non-gating benchmark harness records repeated viewport-change cost without flaky shared-runner thresholds.

Every production bug in scale calculation or coordinate transformation should become a regression test.

## 11. Release policy

The `0.1.0-rc.x` series is the real-application validation period for the documented API contract. New scale policies and rendering options are intentionally deferred until the existing contracts have been validated outside the package test suite.

A `1.0.0` release will adopt semantic-versioning compatibility guarantees for the core public API.
