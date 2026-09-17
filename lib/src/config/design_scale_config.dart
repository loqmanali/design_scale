import 'dart:ui';

import '../domain/scale_limits.dart';
import '../domain/scale_policy.dart';
import '../policies/contain_scale_policy.dart';

/// Immutable configuration used by a [DesignScale] subtree.
class DesignScaleConfig {
  const DesignScaleConfig({
    required this.referenceSize,
    this.policy = const ContainScalePolicy(),
    this.limits = const ScaleLimits(),
  }) : assert(referenceSize.width > 0),
       assert(referenceSize.height > 0);

  /// The design frame against which the UI was authored.
  final Size referenceSize;

  /// Strategy responsible for resolving a uniform scale.
  final ScalePolicy policy;

  /// Optional lower and upper bounds applied to the raw scale.
  final ScaleLimits limits;
}
