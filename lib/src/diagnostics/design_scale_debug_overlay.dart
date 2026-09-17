import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'design_scale_diagnostics.dart';

/// Debug-only overlay that shows the current `DesignScale` runtime state.
///
/// Place this widget below `DesignScale`. In profile and release builds it
/// returns [child] directly and adds no overlay.
final class DesignScaleDebugOverlay extends StatelessWidget {
  const DesignScaleDebugOverlay({
    super.key,
    required this.child,
    this.alignment = Alignment.topLeft,
    this.margin = const EdgeInsets.all(8),
  });

  final Widget child;
  final Alignment alignment;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return child;
    }

    final diagnostics = DesignScaleDiagnostics.of(context);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Align(
          alignment: alignment,
          child: Padding(
            padding: margin,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xD9000000),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    diagnostics.toMultilineString(),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
