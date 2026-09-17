import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../api/design_scale_scope.dart';

/// Snapshot of the current `DesignScale` runtime state for debugging.
///
/// This type is exported only by `package:design_scale/design_scale_debug.dart`.
final class DesignScaleDiagnostics {
  const DesignScaleDiagnostics({
    required this.referenceSize,
    required this.viewportSize,
    required this.virtualSize,
    required this.rawScale,
    required this.scale,
    required this.isClamped,
    required this.policyName,
    required this.displayFeatureCount,
    required this.effectiveTextScale,
  });

  /// Captures diagnostics from the nearest `DesignScaleScope` and `MediaQuery`.
  factory DesignScaleDiagnostics.of(BuildContext context) {
    final scope = DesignScaleScope.of(context);
    final mediaQuery = MediaQuery.of(context);

    return DesignScaleDiagnostics(
      referenceSize: scope.config.referenceSize,
      viewportSize: scope.result.viewportSize,
      virtualSize: scope.result.virtualSize,
      rawScale: scope.result.rawScale,
      scale: scope.result.scale,
      isClamped: scope.result.isClamped,
      policyName: scope.config.policy.runtimeType.toString(),
      displayFeatureCount: mediaQuery.displayFeatures.length,
      effectiveTextScale: mediaQuery.textScaler.scale(1),
    );
  }

  final Size referenceSize;
  final Size viewportSize;
  final Size virtualSize;
  final double rawScale;
  final double scale;
  final bool isClamped;
  final String policyName;
  final int displayFeatureCount;
  final double effectiveTextScale;

  /// Human-readable multi-line representation suitable for logs and overlays.
  String toMultilineString() {
    return <String>[
      'DesignScale',
      'viewport: ${_formatSize(viewportSize)}',
      'reference: ${_formatSize(referenceSize)}',
      'virtual: ${_formatSize(virtualSize)}',
      'raw scale: ${rawScale.toStringAsFixed(4)}',
      'scale: ${scale.toStringAsFixed(4)}',
      'clamped: $isClamped',
      'policy: $policyName',
      'display features: $displayFeatureCount',
      'text scale: ${effectiveTextScale.toStringAsFixed(2)}',
    ].join('\n');
  }

  static String _formatSize(Size size) {
    return '${size.width.toStringAsFixed(1)} × ${size.height.toStringAsFixed(1)}';
  }
}
