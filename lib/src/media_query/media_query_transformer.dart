import 'package:flutter/widgets.dart';

/// Converts spatial MediaQuery values into the virtual design coordinate space.
final class MediaQueryTransformer {
  const MediaQueryTransformer._();

  static MediaQueryData transform({
    required MediaQueryData data,
    required double scale,
    required Size virtualSize,
  }) {
    if (!scale.isFinite || scale <= 0) {
      throw ArgumentError.value(scale, 'scale', 'must be finite and greater than zero');
    }

    return data.copyWith(
      size: virtualSize,
      padding: _scaleInsets(data.padding, scale),
      viewPadding: _scaleInsets(data.viewPadding, scale),
      viewInsets: _scaleInsets(data.viewInsets, scale),
      systemGestureInsets: _scaleInsets(data.systemGestureInsets, scale),
    );
  }

  static EdgeInsets _scaleInsets(EdgeInsets value, double scale) {
    return EdgeInsets.fromLTRB(
      value.left / scale,
      value.top / scale,
      value.right / scale,
      value.bottom / scale,
    );
  }
}
