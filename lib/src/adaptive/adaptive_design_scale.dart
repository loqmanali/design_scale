import 'package:flutter/widgets.dart';

import '../api/design_scale.dart';
import '../api/design_scale_scope.dart';
import 'adaptive_breakpoints.dart';
import 'adaptive_scope.dart';
import 'adaptive_variant.dart';
import 'adaptive_window_class.dart';

/// Selects scaling configuration from the original window BEFORE scaling.
///
/// Place inside MaterialApp.builder or CupertinoApp.builder, passing the
/// provided navigator child through unchanged. Use AdaptiveBuilder inside
/// routes to select their composition. Do not wrap another DesignScale.
///
/// This boundary must occupy the complete, bounded MediaQuery viewport.
/// It does not rebase window insets or hinges for an arbitrary smaller panel.
class AdaptiveDesignScale extends StatelessWidget {
  const AdaptiveDesignScale({
    super.key,
    required this.compact,
    required this.child,
    this.medium,
    this.expanded,
    this.breakpoints = const AdaptiveBreakpoints(),
  });

  /// Required compact configuration and final fallback.
  final AdaptiveVariant compact;

  /// Medium configuration; falls back to [compact] when absent.
  final AdaptiveVariant? medium;

  /// Expanded configuration; falls back to [medium], then [compact].
  final AdaptiveVariant? expanded;

  /// Boundaries in unscaled logical pixels.
  final AdaptiveBreakpoints breakpoints;

  /// Stable subtree, normally the navigator provided by the app builder.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (DesignScaleScope.maybeOf(context) != null) {
      throw FlutterError(
        'AdaptiveDesignScale must be above the scaling boundary. '
        'Replace the existing DesignScale instead of nesting another one. '
        'Use AdaptiveBuilder inside a scaled route.',
      );
    }

    final viewport = MediaQuery.maybeSizeOf(context);
    if (viewport == null) {
      throw FlutterError(
        'AdaptiveDesignScale requires a MediaQuery. Place it inside '
        'MaterialApp.builder or CupertinoApp.builder.',
      );
    }
    if (!viewport.width.isFinite ||
        !viewport.height.isFinite ||
        viewport.width <= 0 ||
        viewport.height <= 0) {
      throw FlutterError(
        'AdaptiveDesignScale requires a finite, positive window size.',
      );
    }

    final windowClass = breakpoints.classify(viewport.width);
    final variant = switch (windowClass) {
      AdaptiveWindowClass.compact => compact,
      AdaptiveWindowClass.medium => medium ?? compact,
      AdaptiveWindowClass.expanded => expanded ?? medium ?? compact,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final matchesViewport = constraints.hasBoundedWidth &&
            constraints.hasBoundedHeight &&
            (constraints.maxWidth - viewport.width).abs() < 0.001 &&
            (constraints.maxHeight - viewport.height).abs() < 0.001;
        if (!matchesViewport) {
          throw FlutterError(
            'AdaptiveDesignScale must fill its MediaQuery viewport. '
            'Place it in the app builder, outside SafeArea and Padding. '
            'Use LayoutBuilder for a local panel instead.',
          );
        }

        // Never key this boundary by windowClass: that would reset routes.
        return AdaptiveScope(
          windowClass: windowClass,
          viewportSize: viewport,
          breakpoints: breakpoints,
          child: DesignScale(
            referenceSize: variant.referenceSize,
            policy: variant.policy,
            limits: variant.limits,
            child: child,
          ),
        );
      },
    );
  }
}
