import 'package:design_scale/design_scale_adaptive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdaptiveBreakpoints', () {
    const breakpoints = AdaptiveBreakpoints();
    const cases = <double, AdaptiveWindowClass>{
      0: AdaptiveWindowClass.compact,
      599.999: AdaptiveWindowClass.compact,
      600: AdaptiveWindowClass.medium,
      839.999: AdaptiveWindowClass.medium,
      840: AdaptiveWindowClass.expanded,
      1920: AdaptiveWindowClass.expanded,
    };

    for (final entry in cases.entries) {
      test('classifies ${entry.key} as ${entry.value.name}', () {
        expect(breakpoints.classify(entry.key), entry.value);
      });
    }

    test('uses custom boundaries with inclusive lower limits', () {
      const custom = AdaptiveBreakpoints(compactEnd: 500, mediumEnd: 1000);
      expect(custom.classify(499), AdaptiveWindowClass.compact);
      expect(custom.classify(500), AdaptiveWindowClass.medium);
      expect(custom.classify(1000), AdaptiveWindowClass.expanded);
    });

    for (final width in [-1.0, double.nan, double.infinity, -double.infinity]) {
      test('rejects invalid width $width', () {
        expect(() => breakpoints.classify(width), throwsArgumentError);
      });
    }

    const invalid = <AdaptiveBreakpoints>[
      AdaptiveBreakpoints(compactEnd: 0),
      AdaptiveBreakpoints(compactEnd: -1),
      AdaptiveBreakpoints(compactEnd: double.nan),
      AdaptiveBreakpoints(compactEnd: double.infinity),
      AdaptiveBreakpoints(mediumEnd: 0),
      AdaptiveBreakpoints(mediumEnd: 599),
      AdaptiveBreakpoints(mediumEnd: 600),
      AdaptiveBreakpoints(mediumEnd: double.nan),
      AdaptiveBreakpoints(mediumEnd: double.infinity),
    ];
    for (var i = 0; i < invalid.length; i += 1) {
      final config = invalid[i];
      test('validates boundary configuration $i at runtime', () {
        expect(() => config.classify(800), throwsArgumentError);
      });
    }

    test('has value equality', () {
      final boundary = double.parse('500');
      final first = AdaptiveBreakpoints(compactEnd: boundary, mediumEnd: 900);
      final second = AdaptiveBreakpoints(compactEnd: boundary, mediumEnd: 900);
      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(breakpoints));
    });
  });

  group('AdaptiveValue', () {
    const columns = AdaptiveValue<int>(compact: 1, medium: 2, expanded: 4);

    test('selects a value without a BuildContext', () {
      expect(columns.resolveFor(AdaptiveWindowClass.compact), 1);
      expect(columns.resolveFor(AdaptiveWindowClass.medium), 2);
      expect(columns.resolveFor(AdaptiveWindowClass.expanded), 4);
    });

    test('preserves an intentional nullable value', () {
      const value = AdaptiveValue<String?>(
        compact: 'compact',
        medium: null,
        expanded: 'expanded',
      );
      expect(value.resolveFor(AdaptiveWindowClass.medium), isNull);
    });
  });

  test('AdaptiveVariant has value equality', () {
    final width = double.parse('375');
    final first = AdaptiveVariant(referenceSize: Size(width, 812));
    final second = AdaptiveVariant(referenceSize: Size(width, 812));
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first, isNot(const AdaptiveVariant(referenceSize: Size(768, 1024))));
  });

  test('AdaptiveScope notifies only when its exposed values change', () {
    const original = AdaptiveScope(
      windowClass: AdaptiveWindowClass.medium,
      viewportSize: Size(800, 1280),
      breakpoints: AdaptiveBreakpoints(),
      child: SizedBox.shrink(),
    );
    const equal = AdaptiveScope(
      windowClass: AdaptiveWindowClass.medium,
      viewportSize: Size(800, 1280),
      breakpoints: AdaptiveBreakpoints(),
      child: SizedBox.expand(),
    );
    const resized = AdaptiveScope(
      windowClass: AdaptiveWindowClass.medium,
      viewportSize: Size(810, 1280),
      breakpoints: AdaptiveBreakpoints(),
      child: SizedBox.shrink(),
    );
    const changedBreakpoints = AdaptiveScope(
      windowClass: AdaptiveWindowClass.medium,
      viewportSize: Size(800, 1280),
      breakpoints: AdaptiveBreakpoints(compactEnd: 500, mediumEnd: 900),
      child: SizedBox.shrink(),
    );
    expect(equal.updateShouldNotify(original), isFalse);
    expect(resized.updateShouldNotify(original), isTrue);
    expect(changedBreakpoints.updateShouldNotify(original), isTrue);
  });
}
