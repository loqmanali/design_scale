# design_scale

Reference-based design scaling for Flutter.

`design_scale` lets an application author against one design reference size while preserving Flutter's native layout and accessibility model. It provides uniform viewport scaling; it is intentionally **not** an adaptive-layout or breakpoint framework.

## Status

Early architecture preview. The package is not yet released to pub.dev.

## Why

A design often starts from a fixed frame such as `375 x 812`. Repeating `.w`, `.h`, `.sp`, or `.r` across a widget tree couples UI code to a sizing package and makes consistency difficult to audit.

`design_scale` keeps normal Flutter values and creates a virtual design viewport instead.

## Quick start

Use `DesignScale` inside the app builder so it receives Flutter's current `MediaQuery` and can transform the subtree consistently:

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

Widgets below `DesignScale` continue to use ordinary Flutter dimensions:

```dart
Container(
  width: 120,
  height: 48,
  padding: const EdgeInsets.all(16),
  child: const Text('Continue'),
)
```

## Window behavior

The virtual coordinate system covers:

- safe-area, keyboard, and system-gesture insets;
- fold, hinge, and cutout bounds from `MediaQuery.displayFeatures`;
- device gesture thresholds;
- resize, rotation, and split-screen changes;
- semantics, pointer hit testing, and coordinate conversion.

Text scaling, accessibility preferences, platform brightness, and
`devicePixelRatio` remain native Flutter values.

Rounded display-corner radii are not transformed while Flutter 3.19 remains the
minimum supported version.

## Scope

`design_scale` owns **uniform design-space scaling**. Your application still owns adaptive composition using tools such as `LayoutBuilder` and breakpoints.

The package is verified against Flutter 3.19.0 and the current stable Flutter channel.

For architecture decisions and quality attributes, see [ARCHITECTURE.md](ARCHITECTURE.md) and [docs/adr](docs/adr).
