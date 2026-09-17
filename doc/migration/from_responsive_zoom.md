# Migrating from responsive_zoom

`design_scale` keeps the reference-design idea while making configuration instance-scoped and the rendering contract explicit.

## Configuration

Instead of mutable/global reference configuration, configure each subtree directly:

```dart
MaterialApp(
  builder: (context, child) {
    return DesignScale(
      referenceSize: const Size(375, 812),
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

For reusable configuration:

```dart
const config = DesignScaleConfig(
  referenceSize: Size(375, 812),
);

DesignScale.config(
  config: config,
  child: child,
);
```

## Behavioral differences

- `design_scale` uses a policy-driven uniform scale.
- The default `ContainScalePolicy` resolves the smaller width/height ratio.
- The application receives extra virtual space on the unconstrained axis instead of independent x/y stretching.
- Rendering uses a dedicated render viewport rather than `FittedBox`.
- `MediaQuery` spatial geometry, foldable bounds, pointer coordinates, and semantics use the same virtual coordinate space.
- `TextScaler`, accessibility settings, and device-pixel ratio are preserved.

## Adaptive layouts

Do not replace `LayoutBuilder` with `DesignScale`. Use both: `DesignScale` normalizes design coordinates; `LayoutBuilder` decides compact, medium, or expanded composition.
