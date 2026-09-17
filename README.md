# design_scale

Reference-based design scaling for Flutter.

`design_scale` lets an application author against one design reference size while preserving Flutter's native layout, window, input, and accessibility model. It provides **uniform design-space scaling**; it is intentionally **not** an adaptive-layout, device-detection, or breakpoint framework.

## Status

`0.1.0-rc.1` release candidate. The public API is being validated in real applications before `1.0.0`.

## Why

A design often starts from a fixed frame such as `375 × 812`. Repeating `.w`, `.h`, `.sp`, or `.r` throughout a widget tree couples presentation code to per-value scaling helpers and makes consistency difficult to audit.

`design_scale` keeps ordinary Flutter dimensions and creates one virtual design viewport instead.

## Quick start

Use `DesignScale` inside `MaterialApp.builder` or `CupertinoApp.builder` so it receives Flutter's current `MediaQuery` and transforms the complete navigator/overlay subtree consistently:

```dart
import 'package:design_scale/design_scale.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return DesignScale(
          referenceSize: const Size(375, 812),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePage(),
    );
  }
}
```

Widgets below `DesignScale` use normal Flutter values:

```dart
Container(
  width: 120,
  height: 48,
  padding: const EdgeInsets.all(16),
  child: const Text('Continue'),
)
```

## Correct integration boundary

Recommended:

- `MaterialApp.builder`
- `CupertinoApp.builder`
- another subtree that already has the correct `MediaQuery`

Do not wrap `MaterialApp` from outside and expect the transformed `MediaQuery` to survive the app's own window/media-query setup.

## Scaling and adaptive layout are separate

`DesignScale` normalizes authored design coordinates. Your application still decides compact, medium, and expanded composition from available space:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 840) {
      return const ExpandedLayout();
    }
    if (constraints.maxWidth >= 600) {
      return const MediumLayout();
    }
    return const CompactLayout();
  },
)
```

In landscape, split-screen, desktop, and tablet scenarios, extra space is exposed as virtual layout space rather than independently stretching width and height.

## Window and input behavior

The virtual coordinate system covers:

- safe-area, keyboard, and system-gesture insets;
- fold, hinge, and cutout bounds from `MediaQuery.displayFeatures`;
- device gesture thresholds;
- resize, rotation, and split-screen changes;
- rendering, pointer hit testing, coordinate conversion, and semantics.

Text scaling, accessibility preferences, platform brightness, and `devicePixelRatio` remain native Flutter values.

Rounded display-corner radii are not transformed while Flutter 3.19 remains the minimum supported version.

## Scale limits

Limits are optional and are applied after the selected policy resolves its raw scale:

```dart
DesignScale(
  referenceSize: const Size(375, 812),
  limits: const ScaleLimits(min: 0.85, max: 1.25),
  child: child,
)
```

Use limits for explicit product constraints, not as a substitute for adaptive composition.

## Debug diagnostics

Debug helpers live in a secondary library so they do not enlarge the core import surface:

```dart
import 'package:design_scale/design_scale.dart';
import 'package:design_scale/design_scale_debug.dart';

DesignScale(
  referenceSize: const Size(375, 812),
  child: DesignScaleDebugOverlay(
    child: child,
  ),
)
```

The overlay reports the physical viewport, reference size, virtual viewport, raw/effective scale, clamp state, policy, display-feature count, and effective text scale. In profile and release builds it returns its child directly.

For programmatic diagnostics:

```dart
final diagnostics = DesignScaleDiagnostics.of(context);
debugPrint(diagnostics.toMultilineString());
```

## Example

A runnable example in [`example/`](example/) demonstrates:

- `MaterialApp.builder` integration;
- ordinary Flutter dimensions;
- `DesignScaleScope`;
- adaptive `LayoutBuilder` composition;
- keyboard behavior;
- the debug overlay.

## Compatibility and verification

The package is continuously verified against:

- Flutter `3.19.0`, the declared minimum;
- the current Flutter stable channel.

CI checks formatting, static analysis, tests/goldens, the example application, coverage execution, and a pub publish dry-run.

## Public API

The intended release-candidate surface is documented in [`docs/public-api.md`](docs/public-api.md). Rendering and geometry implementation under `lib/src` are private and unsupported imports.

## Migration

- [From responsive_zoom](docs/migration/from_responsive_zoom.md)
- [From flutter_screenutil](docs/migration/from_flutter_screenutil.md)

## Performance

A non-gating benchmark harness is available under [`benchmark/`](benchmark/). Timing thresholds are intentionally not enforced on shared CI runners because they are noisy; performance comparisons should be recorded on controlled hardware.

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) and [docs/adr](docs/adr) for architectural drivers, invariants, rendering decisions, compatibility policy, and rationale.
