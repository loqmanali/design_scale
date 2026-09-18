import 'package:flutter/widgets.dart';

import 'adaptive_breakpoints.dart';
import 'adaptive_window_class.dart';

/// Original window metrics retained below the scaling boundary.
///
/// Installed by AdaptiveDesignScale and AdaptiveBuilder. Descendants reading
/// [of] subscribe to changes in the class, viewport size, or breakpoints.
class AdaptiveScope extends InheritedWidget {
  const AdaptiveScope({
    super.key,
    required this.windowClass,
    required this.viewportSize,
    required this.breakpoints,
    required super.child,
  });

  /// Class of the original window, even when a variant falls back.
  final AdaptiveWindowClass windowClass;

  /// Unscaled logical pixels, NOT device/physical pixels or virtual pixels.
  final Size viewportSize;

  /// Boundaries used to classify [viewportSize].
  final AdaptiveBreakpoints breakpoints;

  /// Reads and subscribes to the nearest adaptive scope.
  static AdaptiveScope of(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) {
      throw FlutterError(
        'No AdaptiveScope found. Place this widget below '
        'AdaptiveDesignScale or AdaptiveBuilder.',
      );
    }
    return scope;
  }

  /// Reads and subscribes to a scope, or returns null when absent.
  static AdaptiveScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdaptiveScope>();
  }

  @override
  bool updateShouldNotify(AdaptiveScope oldWidget) {
    return windowClass != oldWidget.windowClass ||
        viewportSize != oldWidget.viewportSize ||
        breakpoints != oldWidget.breakpoints;
  }
}
