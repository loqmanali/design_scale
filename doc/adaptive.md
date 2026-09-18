# Optional adaptive composition

**Status: unreleased feature-branch implementation; Flutter validation pending.**
The package version is intentionally unchanged. Importing the core alone does
not enable or depend on adaptive behavior.

## Two separate responsibilities

- **Scaling:** retain proportions within a selected reference design.
- **Adaptation:** select a composition supplied by the application.

```text
Original window logical size
  -> AdaptiveBreakpoints
  -> compact / medium / expanded
  -> select reference size, policy, limits
  -> AdaptiveScope (original window metrics)
  -> existing DesignScale (virtual MediaQuery + render transform)
  -> same Navigator
  -> route's AdaptiveBuilder selects its composition
```

## Integrate without replacing the navigator

Replace your existing DesignScale wrapper; do not wrap it in another scaler.

```dart
import 'package:design_scale/design_scale_adaptive.dart';
import 'package:flutter/material.dart';

MaterialApp(
  builder: (context, child) => AdaptiveDesignScale(
    compact: const AdaptiveVariant(referenceSize: Size(375, 812)),
    medium: const AdaptiveVariant(referenceSize: Size(768, 1024)),
    expanded: const AdaptiveVariant(referenceSize: Size(1440, 900)),
    child: child ?? const SizedBox.shrink(),
  ),
  home: AdaptiveBuilder(
    compact: (_) => const CompactHome(),
    medium: (_) => const MediumHome(),
    expanded: (_) => const ExpandedHome(),
  ),
)
```

`CompactHome`, `MediumHome`, and `ExpandedHome` are your widgets, not package
classes. A complete example is in `example/lib/adaptive_main.dart`.
The same integration pattern applies to CupertinoApp.builder.

**API refinement:** AdaptiveVariant is configuration-only; it has no `builder`
parameter. AdaptiveBuilder selects layouts inside routes, avoiding three app
roots and accidental navigator replacement.

Place SafeArea and page padding inside your route. The combined scaler must
occupy its incoming MediaQuery viewport; a partial or unbounded viewport gives
an explicit FlutterError instead of mixing coordinate origins.

## Breakpoints

| Width in original logical pixels | Default class |
| --- | --- |
| less than 600 | compact |
| 600 or more, less than 840 | medium |
| 840 or more | expanded |

```dart
const AdaptiveBreakpoints(compactEnd: 500, mediumEnd: 1000)
```

Classification validates finite non-negative width and finite ordered positive
boundaries in all build modes. Zero classifies as compact; the combined scaling
widget, like the existing engine, requires a finite positive viewport.

Widths are NOT device pixels. A 1200-pixel display at devicePixelRatio 3 has
400 logical pixels and is compact. Split-screen uses the app window's width.

A bare LayoutBuilder below DesignScale sees virtual constraints, which can
be useful for fitting content but are not the original window width. Do not
reuse window thresholds there without deciding which coordinate space you need.

## Fallbacks

Compact is required. Medium falls back to compact. Expanded falls back to
medium, then compact. These rules apply separately to scaling variants and
layout builders. Only the selected builder executes.

Fallback does not relabel the window: an expanded window may use a medium
reference and builder while AdaptiveScope.windowClass stays expanded.

## Layout-only use

AdaptiveBuilder can also work without AdaptiveDesignScale:

- below plain MaterialApp, it reads the current MediaQuery window size;
- below a single existing DesignScale, it uses that scope's original viewport;
- below AdaptiveScope, it inherits the scope's original size and breakpoints.

Its optional `breakpoints` overrides inherited boundaries for that builder and
its descendants. Otherwise it inherits them, or uses defaults. This is always
**window-level** behavior, even when the builder sits inside a narrow panel.
Use LayoutBuilder for panel-specific composition. Nested global scalers are
not a supported way to create panels.

## Read the original metrics

```dart
final adaptive = AdaptiveScope.of(context);
final windowClass = adaptive.windowClass;
final originalLogicalSize = adaptive.viewportSize;
```

The context passed to a selected AdaptiveBuilder callback is below its scope.
Do not read that scope from the parent context used to construct the widget.

## Adaptive values and per-class limits

```dart
const columnChoices = AdaptiveValue<int>(
  compact: 1,
  medium: 2,
  expanded: 3,
);
final columns = columnChoices.resolve(context);
```

All values are required, including intentionally nullable values. `resolveFor`
accepts an AdaptiveWindowClass without a BuildContext. Use these values for
column count, padding, or layout choices, not every dimension.

Core types still use the core import:

```dart
import 'package:design_scale/design_scale.dart';
import 'package:design_scale/design_scale_adaptive.dart';

const desktop = AdaptiveVariant(
  referenceSize: Size(1440, 900),
  limits: ScaleLimits(min: 1, max: 1),
);
```

Each variant can use a custom ScalePolicy. A variant's reference configuration
is validated by the core when selected. Changing reference sizes at a boundary
can change zoom abruptly; choose frames and limits intentionally.

## State and performance

The combined wrapper retains a stable subtree structure and never adds a key
based on the window class. That avoids deliberately resetting the navigator.
It cannot preserve state of arbitrary CompactHome/MediumHome widget types that
Flutter replaces. Hoist shared state/controllers above AdaptiveBuilder, as the
example does for notes, selected navigation index, and a counter.

There is no timer, animation controller, or periodic rebuild scheduler in this
library. Scope readers react when class, original size, or breakpoints change;
parent and MediaQuery dependencies can also cause normal Flutter rebuilds.
Size changes within a class can legitimately notify scope readers. These are
source-level properties, NOT measured runtime performance guarantees.

Text scaling, window insets, hit testing, and rendering still go through the
existing core. This does not automatically solve accessibility constraints,
minimum tap targets, local pane geometry, or all foldable layouts. No profiler
measurements or device screenshots have been produced for this addition.

## Run the example locally

```bash
cd example
flutter pub get
# Existing repository example has no checked-in platform host projects.
# Generate the host for your chosen platform locally; do not commit it blindly.
flutter create --platforms=web .
flutter run -d chrome -t lib/adaptive_main.dart
```

Review generated files: flutter create may update local project metadata. For
Android or iOS, generate that platform's host instead and use a configured
emulator/device. Web screenshots do not constitute mobile performance evidence.

## Local validation before any PR

```bash
# From repository root. This script does not push or trigger Actions.
bash tool/validate_adaptive.sh
```

Formatting is deliberately a check, not an automatic remote fix. If it fails,
run `dart format lib test example benchmark`, inspect the changes, and rerun
locally. Validate on Flutter 3.19.0 and your current stable SDK before declaring
compatibility. Keep device performance testing separate from widget tests.

See [validation status](adaptive-validation.md) for what has and has not run.
