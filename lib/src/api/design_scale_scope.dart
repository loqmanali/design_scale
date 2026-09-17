import 'package:flutter/widgets.dart';

import '../config/design_scale_config.dart';
import '../domain/scale_result.dart';

/// Runtime scaling information exposed to descendants of [DesignScale].
class DesignScaleScope extends InheritedWidget {
  const DesignScaleScope({
    super.key,
    required this.config,
    required this.result,
    required super.child,
  });

  /// Configuration used to resolve the current result.
  final DesignScaleConfig config;

  /// Current resolved scale and virtual viewport.
  final ScaleResult result;

  static DesignScaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DesignScaleScope>();
    assert(scope != null, 'No DesignScaleScope found in this context.');
    return scope!;
  }

  static DesignScaleScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DesignScaleScope>();
  }

  @override
  bool updateShouldNotify(DesignScaleScope oldWidget) {
    return oldWidget.result.scale != result.scale ||
        oldWidget.result.virtualSize != result.virtualSize ||
        oldWidget.config.referenceSize != config.referenceSize ||
        oldWidget.config.policy.runtimeType != config.policy.runtimeType;
  }
}
