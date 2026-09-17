import 'dart:ui';

import 'scale_limits.dart';

/// Immutable result produced by a scale policy.
class ScaleResult {
  const ScaleResult._({
    required this.rawScale,
    required this.scale,
    required this.viewportSize,
    required this.referenceSize,
    required this.virtualSize,
    required this.isClamped,
  });

  factory ScaleResult.fromRaw({
    required double rawScale,
    required Size viewportSize,
    required Size referenceSize,
    required ScaleLimits limits,
  }) {
    if (!rawScale.isFinite || rawScale <= 0) {
      throw StateError('A scale policy must resolve a finite scale greater than zero.');
    }

    final scale = limits.apply(rawScale);

    return ScaleResult._(
      rawScale: rawScale,
      scale: scale,
      viewportSize: viewportSize,
      referenceSize: referenceSize,
      virtualSize: Size(viewportSize.width / scale, viewportSize.height / scale),
      isClamped: scale != rawScale,
    );
  }

  /// Scale before limits are applied.
  final double rawScale;

  /// Effective uniform scale.
  final double scale;

  /// Physical/logical viewport size observed from Flutter.
  final Size viewportSize;

  /// Design reference size used by the policy.
  final Size referenceSize;

  /// Viewport exposed to the scaled child coordinate system.
  final Size virtualSize;

  /// Whether [scale] differs from [rawScale] because of [ScaleLimits].
  final bool isClamped;
}
