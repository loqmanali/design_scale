# Public API contract

This document defines the intended release-candidate public surface for `design_scale`.

## Core library

Import:

```dart
import 'package:design_scale/design_scale.dart';
```

The core public API is intentionally small:

- `DesignScale`
- `DesignScaleConfig`
- `DesignScaleScope`
- `ScalePolicy`
- `ScaleInput`
- `ScaleResult`
- `ScaleLimits`
- `ContainScalePolicy`

Rendering primitives, MediaQuery adapters, geometry transformers, and other implementation details remain private under `lib/src`.

## Debug library

Import:

```dart
import 'package:design_scale/design_scale_debug.dart';
```

Debug helpers are kept in a secondary library so applications that only need scaling do not depend on diagnostic UI:

- `DesignScaleDiagnostics`
- `DesignScaleDebugOverlay`

The debug overlay is active only in debug builds. In profile and release builds it returns its child directly.

## Compatibility promise

During the `0.1.0-rc.x` series:

- existing core names and semantics should not change without a documented reason;
- additions may still occur when they do not invalidate existing code;
- implementation details under `lib/src` are not supported imports;
- adaptive layout decisions remain outside the package contract;
- accessibility values such as `TextScaler` remain native Flutter behavior.

A `1.0.0` release will freeze this contract under semantic versioning.
