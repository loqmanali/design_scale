import 'package:flutter/widgets.dart';

import '../config/design_scale_config.dart';
import '../domain/scale_input.dart';
import '../domain/scale_limits.dart';
import '../domain/scale_policy.dart';
import '../media_query/media_query_transformer.dart';
import '../policies/contain_scale_policy.dart';
import '../rendering/design_scale_viewport.dart';
import 'design_scale_scope.dart';

/// Creates a uniform virtual design viewport for [child].
///
/// Place this widget inside `MaterialApp.builder`, `CupertinoApp.builder`, or
/// another subtree that already has a [MediaQuery].
class DesignScale extends StatelessWidget {
  const DesignScale({
    super.key,
    required this.referenceSize,
    required this.child,
    this.policy = const ContainScalePolicy(),
    this.limits = const ScaleLimits(),
  });

  /// Creates a scaled subtree from an explicit immutable configuration object.
  factory DesignScale.config({
    Key? key,
    required DesignScaleConfig config,
    required Widget child,
  }) {
    return DesignScale(
      key: key,
      referenceSize: config.referenceSize,
      policy: config.policy,
      limits: config.limits,
      child: child,
    );
  }

  /// Design frame against which dimensions were authored.
  final Size referenceSize;

  /// Strategy that resolves a single uniform scale.
  final ScalePolicy policy;

  /// Optional bounds for the scale resolved by [policy].
  final ScaleLimits limits;

  /// Widget subtree rendered in the virtual design coordinate system.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      throw FlutterError(
        'DesignScale requires a MediaQuery. Place it inside MaterialApp.builder, '
        'CupertinoApp.builder, or below an equivalent MediaQuery boundary.',
      );
    }

    final config = DesignScaleConfig(
      referenceSize: referenceSize,
      policy: policy,
      limits: limits,
    );

    final result = policy.resolve(
      ScaleInput(
        viewportSize: mediaQuery.size,
        referenceSize: referenceSize,
        limits: limits,
      ),
    );

    final transformedMediaQuery = MediaQueryTransformer.transform(
      data: mediaQuery,
      scale: result.scale,
      virtualSize: result.virtualSize,
    );

    return DesignScaleViewport(
      scale: result.scale,
      virtualSize: result.virtualSize,
      child: MediaQuery(
        data: transformedMediaQuery,
        child: DesignScaleScope(
          config: config,
          result: result,
          child: child,
        ),
      ),
    );
  }
}
