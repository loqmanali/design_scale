# ADR-0009: Optional adaptive composition before scaling

- Status: Proposed (implementation pending Flutter validation)
- Date: 2026-09-18
- Amends: ADR-0001 and ADR-0008 for the optional library only

## Context

Users now need explicit compact, medium, and expanded layouts in addition to
uniform scaling. Making the core infer layouts would violate its small,
predictable contract. Using virtual MediaQuery width as a window breakpoint
also misclassifies larger windows: 800 x 1280 with a 375 x 812 reference can
produce approximately 507 x 812 virtual space.

Changing an entire MaterialApp or keying its navigator by window class would
reset navigation and local state when resizing.

## Decision

1. Add `design_scale_adaptive.dart` as a separate opt-in barrel. Core/debug
   exports, rendering, dependencies, version, and workflows stay unchanged.
2. `AdaptiveDesignScale` reads the incoming window's logical size before
   invoking the existing `DesignScale` engine. No device-type detection.
3. Variants contain only reference size, policy, and limits. A stable `child`
   is required so MaterialApp/CupertinoApp keep one navigator/overlay subtree.
4. `AdaptiveBuilder` inside routes selects application-supplied compositions.
   It consults AdaptiveScope, then a core DesignScaleScope's original viewport,
   then MediaQuery. It explicitly measures the window, not local panels.
5. Missing medium/expanded variants and builders fall back toward compact.
   The reported window class remains the actual class, not the fallback class.
6. Defaults are compact width <600, medium 600..<840, expanded >=840. These
   are configurable product defaults, not universal rules or physical pixels.
7. AdaptiveScope retains original logical metrics below scaling. Notifications
   depend on class, size, and breakpoint value equality. No timers, polling,
   controller, automatic transition animation, or mutable global config.
8. Reject nested global scaling and partial/unbounded app viewports instead of
   pretending window insets/hinges are panel-relative. The combined wrapper
   belongs outside SafeArea/Padding in the app builder. Local panels continue
   to use LayoutBuilder with a deliberately chosen coordinate system.
9. AdaptiveValue requires three explicit values; nullable values do not fall
   through. Use it for design choices, not a replacement `.w/.sp` syntax.

## Consequences and limits

- Core-only consumers are unaffected. Applications still own the actual
  widgets, navigation design, and shared state.
- Stable navigator identity can preserve routes; switching arbitrary layout
  widget types does NOT guarantee preserving all child state. Hoist models,
  form controllers, and important state above AdaptiveBuilder.
- A reference-size change may create a visible scale discontinuity at a
  breakpoint. No claim of smooth or optimal adaptation is made.
- Scope consumers are notified on size changes within the same class because
  the scope exposes size. There is no claim of zero rebuilds while resizing.
- No automatic height classes, input-modality adaptation, hinge/pane splitting,
  platform-specific controls, or custom panel-coordinate transformation.
- Validation and profiling remain required before merge or release. Existing
  core CI results do not validate this new library.

## Alternatives considered

- Put breakpoints in core: rejected; expands the default dependency contract.
- Infer classes from virtual width: rejected for window-level decisions.
- Build a separate MaterialApp for every variant: rejected; risks route reset.
- Rebase window geometry for arbitrary panels now: deferred as a separate
  rendering/geometry feature with its own verification burden.

## References

- https://docs.flutter.dev/ui/adaptive-responsive/general
- https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html
- https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html
