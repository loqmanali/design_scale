import 'package:flutter/widgets.dart';

import '../api/design_scale_scope.dart';
import 'adaptive_breakpoints.dart';
import 'adaptive_scope.dart';
import 'adaptive_window_class.dart';

/// Selects a layout using the original WINDOW width, not local constraints.
///
/// Reads an AdaptiveScope first, then an existing DesignScaleScope's original
/// viewport, then MediaQuery. A child builder receives a context below the new
/// adaptive scope, so AdaptiveValue and AdaptiveScope work inside it.
///
/// Only the selected builder runs. Different widget types/keys still follow
/// normal Flutter state disposal rules; hoist shared state above this widget.
class AdaptiveBuilder extends StatelessWidget {
  const AdaptiveBuilder({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.breakpoints,
  });

  /// Required compact builder and final fallback.
  final WidgetBuilder compact;

  /// Medium builder; falls back to [compact] when absent.
  final WidgetBuilder? medium;

  /// Expanded builder; falls back to [medium], then [compact].
  final WidgetBuilder? expanded;

  /// Overrides inherited boundaries. Null inherits or uses the defaults.
  final AdaptiveBreakpoints? breakpoints;

  @override
  Widget build(BuildContext context) {
    final inherited = AdaptiveScope.maybeOf(context);
    final Size viewport;
    if (inherited != null) {
      viewport = inherited.viewportSize;
    } else {
      final scaling = DesignScaleScope.maybeOf(context);
      final originalSize =
          scaling?.result.viewportSize ?? MediaQuery.maybeSizeOf(context);
      if (originalSize == null) {
        throw FlutterError(
          'AdaptiveBuilder requires AdaptiveScope, DesignScaleScope, '
          'or MediaQuery to read the original window size.',
        );
      }
      viewport = originalSize;
    }

    final effectiveBreakpoints =
        breakpoints ?? inherited?.breakpoints ?? const AdaptiveBreakpoints();
    final windowClass = effectiveBreakpoints.classify(viewport.width);
    final builder = switch (windowClass) {
      AdaptiveWindowClass.compact => compact,
      AdaptiveWindowClass.medium => medium ?? compact,
      AdaptiveWindowClass.expanded => expanded ?? medium ?? compact,
    };

    return AdaptiveScope(
      windowClass: windowClass,
      viewportSize: viewport,
      breakpoints: effectiveBreakpoints,
      child: Builder(builder: builder),
    );
  }
}
