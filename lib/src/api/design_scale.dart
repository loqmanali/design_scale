import 'package:flutter/widgets.dart';

import '../config/design_scale_config.dart';
import '../domain/scale_input.dart';
import '../domain/scale_limits.dart';
import '../domain/scale_policy.dart';
import '../media_query/media_query_transformer.dart';
import '../policies/contain_scale_policy.dart';
import 'design_scale_scope.dart';

/// Creates a uniform virtual design viewport for [child].
///
/// Place this widget inside `MaterialApp.builder`, `CupertinoApp.builder`, or
/// another subtree that already has a [MediaQuery].
class DesignScale extends StatelessWidget {
  const DesignScale({
    super.key,
    required Size referenceSize,
    required this.child,
    ScalePolicy policy = const ContainScalePolicy(),
    ScaleLimits limits = const ScaleLimits(),
  }) : config = DesignScaleConfig(
         referenceSize: referenceSize,
         policy: policy,
         limits: limits,
       );

  /// Creates a scaled subtree from an explicit immutable configuration object.
  const DesignScale.config({
    super.key,
    required this.config,
    required this.child,
  });

  /// Configuration that drives scale resolution for this subtree.
  final DesignScaleConfig config;

  /// Widget subtree rendered in the virtual design coordinate system.
  final Widget child;

  /// Design frame against which dimensions were authored.
  Size get referenceSize => config.referenceSize;

  /// Strategy that resolves a single uniform scale.
  ScalePolicy get policy => config.policy;

  /// Optional bounds for the scale resolved by [policy].
  ScaleLimits get limits => config.limits;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      throw FlutterError(
        'DesignScale requires a MediaQuery. Place it inside MaterialApp.builder, '
        'CupertinoApp.builder, or below an equivalent MediaQuery boundary.',
      );
    }

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

    return SizedBox(
      width: mediaQuery.size.width,
      height: mediaQuery.size.height,
      child: FittedBox(
        alignment: Alignment.topLeft,
        fit: BoxFit.fill,
        child: SizedBox(
          width: result.virtualSize.width,
          height: result.virtualSize.height,
          child: MediaQuery(
            data: transformedMediaQuery,
            child: DesignScaleScope(
              config: config,
              result: result,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
