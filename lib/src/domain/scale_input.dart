import 'dart:ui';

import 'scale_limits.dart';

/// Immutable input for a [ScalePolicy].
class ScaleInput {
  const ScaleInput({
    required this.viewportSize,
    required this.referenceSize,
    this.limits = const ScaleLimits(),
  }) : assert(viewportSize.width > 0),
       assert(viewportSize.height > 0),
       assert(referenceSize.width > 0),
       assert(referenceSize.height > 0);

  /// Current logical viewport size supplied by Flutter.
  final Size viewportSize;

  /// Reference design frame.
  final Size referenceSize;

  /// Optional scale bounds.
  final ScaleLimits limits;
}
