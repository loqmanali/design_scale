import 'scale_input.dart';
import 'scale_result.dart';

/// Resolves a uniform scale for a viewport and a reference design frame.
abstract interface class ScalePolicy {
  const ScalePolicy();

  ScaleResult resolve(ScaleInput input);
}
