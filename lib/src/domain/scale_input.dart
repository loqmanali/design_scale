import 'dart:ui';

import 'scale_limits.dart';

/// Immutable input for a `ScalePolicy`.
class ScaleInput {
  const ScaleInput({
    required this.viewportSize,
    required this.referenceSize,
    this.limits = const ScaleLimits(),
  });

  /// Current logical viewport size supplied by Flutter.
  final Size viewportSize;

  /// Reference design frame.
  final Size referenceSize;

  /// Optional scale bounds.
  final ScaleLimits limits;
}
