# design_scale Architecture

## 1. Problem statement

Flutter applications are commonly authored from a reference design frame. Teams often compensate for varying screens by scattering width, height, radius, and font-size extensions through presentation code. `design_scale` instead creates a stable virtual design space and uniformly maps it to the current Flutter viewport.

The package is a **design-space scaling engine**, not an adaptive-layout framework.

## 2. Architectural drivers

In priority order:

1. **Correctness** — the same inputs produce the same scale.
2. **Predictability** — scaling behavior must be explicit and policy-driven.
3. **Accessibility preservation** — do not override `TextScaler`, accessibility flags, or device pixel ratio.
4. **Window adaptability** — react to the current Flutter `MediaQuery`, including resize and rotation.
5. **Testability** — scale math is pure and testable without pumping widgets.
6. **Extensibility** — new scale policies can be added without changing the rendering API.
7. **Performance** — scale resolution is O(1) and no external runtime dependency is required.
8. **Simplicity** — the default public API remains small.

## 3. Invariants

- Use one uniform scale factor; never independently stretch x and y.
- Configuration is instance-scoped and immutable from the package perspective.
- No global mutable reference size.
- Never rewrite `devicePixelRatio`.
- Never rewrite `TextScaler` or accessibility preferences.
- Scale math lives outside the widget/rendering layer.
- `design_scale` never decides whether the application should use mobile, tablet, or desktop composition.
- Integration happens below `MaterialApp`/`CupertinoApp` through their builder callback.

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
virtual   rendering
MediaQuery transform
     \   /
      v v
  application subtree
```

## 5. Layers

```text
lib/src/
  api/          Public widget and inherited scope
  config/       Public immutable configuration values
  domain/       Pure inputs, results, limits, policy contract
  policies/     Scale-policy implementations
  media_query/  Flutter MediaQuery adapter
  rendering/    Reserved for the dedicated render engine
```

Dependency direction is toward the domain contracts. Rendering and Flutter adapters may depend on domain types; domain math does not depend on widget state or app lifecycle.

## 6. Default scale policy

`ContainScalePolicy` computes:

```text
widthScale  = viewportWidth  / referenceWidth
heightScale = viewportHeight / referenceHeight
scale       = min(widthScale, heightScale)
virtualSize = viewportSize / scale
```

This keeps the scale uniform and exposes any extra axis as virtual layout space instead of distorting the design.

## 7. MediaQuery contract

Spatial values are transformed into virtual design-space coordinates:

- `size`
- `padding`
- `viewPadding`
- `viewInsets`
- `systemGestureInsets`

Non-spatial platform/accessibility values remain unchanged, including device pixel ratio, text scaling, brightness, high contrast, navigation mode, and accessibility flags.

Foldable `displayFeatures` transformation is intentionally not claimed in the first architecture slice; explicit support must be added together with dedicated tests before the package advertises foldable support.

## 8. Rendering evolution

The first slice uses Flutter's existing fitted rendering primitive so the domain and MediaQuery contracts can stabilize early. A dedicated `RenderDesignScaleViewport` is planned behind the same public contract for explicit layout, paint, hit-test, and semantics control.

The rendering implementation is private and replaceable; consumers must not depend on it.

## 9. Testing strategy

- **Unit:** policy math, limits, invalid configuration.
- **Widget:** MediaQuery transformation and scope behavior.
- **Golden:** representative phone/tablet/desktop viewports (next phase).
- **Integration:** rotation, keyboard, resize, and platform verification (next phase).

Every production bug in scale calculation or coordinate transformation should become a regression test.
