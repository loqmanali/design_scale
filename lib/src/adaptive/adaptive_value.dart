import 'package:flutter/widgets.dart';

import 'adaptive_scope.dart';
import 'adaptive_window_class.dart';

/// An explicit design choice per window class (columns, padding, etc.).
///
/// All values are required. Nullable T is supported without treating an
/// intentional null as a missing value. This is not a per-dimension scaler.
class AdaptiveValue<T> {
  const AdaptiveValue({
    required this.compact,
    required this.medium,
    required this.expanded,
  });

  /// Value for compact windows.
  final T compact;

  /// Value for medium windows.
  final T medium;

  /// Value for expanded windows.
  final T expanded;

  /// Selects from the nearest AdaptiveScope and subscribes to its updates.
  T resolve(BuildContext context) {
    return resolveFor(AdaptiveScope.of(context).windowClass);
  }

  /// Selects without a widget dependency; useful in pure tests.
  T resolveFor(AdaptiveWindowClass windowClass) {
    return switch (windowClass) {
      AdaptiveWindowClass.compact => compact,
      AdaptiveWindowClass.medium => medium,
      AdaptiveWindowClass.expanded => expanded,
    };
  }
}
