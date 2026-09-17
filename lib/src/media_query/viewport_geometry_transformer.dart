import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Converts platform window geometry into the virtual design coordinate space.
///
/// Every value handled here is expressed in logical pixels. A physical Flutter
/// viewport value is divided by the resolved uniform scale before it is exposed
/// to widgets below `DesignScale`.
final class ViewportGeometryTransformer {
  const ViewportGeometryTransformer._();

  /// Converts edge insets into virtual design-space coordinates.
  static EdgeInsets toVirtualInsets(EdgeInsets value, double scale) {
    _validateScale(scale);

    if (scale == 1) {
      return value;
    }

    return EdgeInsets.fromLTRB(
      value.left / scale,
      value.top / scale,
      value.right / scale,
      value.bottom / scale,
    );
  }

  /// Converts a rectangle into virtual design-space coordinates.
  static Rect toVirtualRect(Rect value, double scale) {
    _validateScale(scale);

    if (scale == 1) {
      return value;
    }

    return Rect.fromLTRB(
      value.left / scale,
      value.top / scale,
      value.right / scale,
      value.bottom / scale,
    );
  }

  /// Converts fold, hinge, and cutout bounds while preserving their metadata.
  static List<ui.DisplayFeature> toVirtualDisplayFeatures(
    List<ui.DisplayFeature> features,
    double scale,
  ) {
    _validateScale(scale);

    if (features.isEmpty || scale == 1) {
      return features;
    }

    return List<ui.DisplayFeature>.unmodifiable(
      features.map(
        (feature) => ui.DisplayFeature(
          bounds: toVirtualRect(feature.bounds, scale),
          type: feature.type,
          state: feature.state,
        ),
      ),
    );
  }

  /// Converts gesture thresholds so they describe the same physical distance
  /// after pointer events enter the virtual coordinate space.
  static DeviceGestureSettings toVirtualGestureSettings(
    DeviceGestureSettings settings,
    double scale,
  ) {
    _validateScale(scale);

    final touchSlop = settings.touchSlop;
    if (touchSlop == null || scale == 1) {
      return settings;
    }

    return DeviceGestureSettings(touchSlop: touchSlop / scale);
  }

  static void _validateScale(double value) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(
        value,
        'scale',
        'must be finite and greater than zero',
      );
    }
  }
}
