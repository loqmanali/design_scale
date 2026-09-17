import 'package:design_scale/src/media_query/media_query_transformer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transforms spatial metrics and preserves platform metrics', () {
    const original = MediaQueryData(
      size: Size(800, 1600),
      devicePixelRatio: 3,
      padding: EdgeInsets.fromLTRB(20, 40, 20, 60),
      viewPadding: EdgeInsets.fromLTRB(24, 48, 24, 72),
      viewInsets: EdgeInsets.only(bottom: 600),
      systemGestureInsets: EdgeInsets.all(16),
      accessibleNavigation: true,
      highContrast: true,
    );

    final transformed = MediaQueryTransformer.transform(
      data: original,
      scale: 2,
      virtualSize: const Size(400, 800),
    );

    expect(transformed.size, const Size(400, 800));
    expect(transformed.padding, const EdgeInsets.fromLTRB(10, 20, 10, 30));
    expect(transformed.viewPadding, const EdgeInsets.fromLTRB(12, 24, 12, 36));
    expect(transformed.viewInsets, const EdgeInsets.only(bottom: 300));
    expect(transformed.systemGestureInsets, const EdgeInsets.all(8));

    expect(transformed.devicePixelRatio, original.devicePixelRatio);
    expect(transformed.textScaler, original.textScaler);
    expect(transformed.accessibleNavigation, isTrue);
    expect(transformed.highContrast, isTrue);
  });
}
