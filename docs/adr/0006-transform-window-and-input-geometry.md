# ADR-0006: Transform window and input geometry as one coordinate system

- **Status:** Accepted
- **Date:** 2026-09-17

## Context

`design_scale` exposes a virtual logical-pixel coordinate system below
`DesignScale`. Transforming only `MediaQueryData.size` and edge insets is not
sufficient. Other values also describe positions or distances in the original
Flutter viewport:

- `DisplayFeature.bounds` describes fold, hinge, and cutout geometry.
- `DeviceGestureSettings.touchSlop` describes a gesture threshold in logical
  pixels.

Leaving either value unchanged would mix physical viewport coordinates with
virtual design coordinates. A hinge could appear in the wrong location, and a
gesture could require a different physical movement distance after scaling.

## Decision

Introduce an internal `ViewportGeometryTransformer` and use it from
`MediaQueryTransformer`.

The transformer:

1. divides spatial coordinates and distances by the resolved uniform scale;
2. transforms every `DisplayFeature.bounds` rectangle;
3. preserves each display feature's `type` and `state`;
4. transforms `DeviceGestureSettings.touchSlop`;
5. preserves object identity when the scale is `1` or no conversion is needed;
6. rejects non-finite or non-positive scale values.

Non-spatial platform and accessibility data remains unchanged.

`MediaQueryData.displayCornerRadii` is not transformed in this release. The
package still supports Flutter 3.19, whose `MediaQueryData` contract does not
expose that property. We will not use dynamic invocation or reflection to
simulate a version-dependent API. Support can be added when the package's
minimum Flutter version moves to a release that exposes the property.

## Consequences

### Positive

- Fold, hinge, and cutout geometry is correct in the virtual viewport.
- Gesture thresholds continue to represent the same physical movement.
- Coordinate conversion rules are centralized in one pure, testable component.
- Flutter 3.19 compatibility is retained.

### Trade-offs

- New spatial `MediaQueryData` fields must be reviewed explicitly when Flutter
  adds them.
- Rounded display-corner geometry remains a documented limitation while Flutter
  3.19 is supported.

## Validation

Tests cover:

- hinge and fold rectangles;
- feature type and posture preservation;
- gesture-threshold conversion;
- keyboard and safe-area insets;
- a foldable integration scenario;
- invalid scale values.
