import 'package:flutter/widgets.dart';

import 'viewport_geometry_transformer.dart';

/// Converts spatial MediaQuery values into the virtual design coordinate space.
final class MediaQueryTransformer {
  const MediaQueryTransformer._();

  static MediaQueryData transform({
    required MediaQueryData data,
    required double scale,
    required Size virtualSize,
  }) {
    if (!scale.isFinite || scale <= 0) {
      throw ArgumentError.value(
        scale,
        'scale',
        'must be finite and greater than zero',
      );
    }

    return data.copyWith(
      size: virtualSize,
      padding: ViewportGeometryTransformer.toVirtualInsets(
        data.padding,
        scale,
      ),
      viewPadding: ViewportGeometryTransformer.toVirtualInsets(
        data.viewPadding,
        scale,
      ),
      viewInsets: ViewportGeometryTransformer.toVirtualInsets(
        data.viewInsets,
        scale,
      ),
      systemGestureInsets: ViewportGeometryTransformer.toVirtualInsets(
        data.systemGestureInsets,
        scale,
      ),
      gestureSettings: ViewportGeometryTransformer.toVirtualGestureSettings(
        data.gestureSettings,
        scale,
      ),
      displayFeatures: ViewportGeometryTransformer.toVirtualDisplayFeatures(
        data.displayFeatures,
        scale,
      ),
    );
  }
}
