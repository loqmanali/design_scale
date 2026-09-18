import 'package:flutter/widgets.dart';

import '../domain/scale_limits.dart';
import '../domain/scale_policy.dart';
import '../policies/contain_scale_policy.dart';

/// Scaling configuration for one window class.
///
/// Layout selection belongs in AdaptiveBuilder inside a route. Keeping a
/// variant configuration-only lets the app retain one navigator across sizes.
class AdaptiveVariant {
  const AdaptiveVariant({
    required this.referenceSize,
    this.policy = const ContainScalePolicy(),
    this.limits = const ScaleLimits(),
  });

  /// Design frame for this class; validated when this variant is resolved.
  final Size referenceSize;

  /// Uniform scaling strategy for this class.
  final ScalePolicy policy;

  /// Optional lower and upper bounds applied by the scaling policy.
  final ScaleLimits limits;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AdaptiveVariant &&
            other.referenceSize == referenceSize &&
            other.policy == policy &&
            other.limits == limits;
  }

  @override
  int get hashCode => Object.hash(referenceSize, policy, limits);
}
