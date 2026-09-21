import 'package:design_scale/design_scale.dart';
import 'package:design_scale/design_scale_adaptive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _compact = AdaptiveVariant(referenceSize: Size(375, 812));
const _medium = AdaptiveVariant(referenceSize: Size(768, 1024));
const _expanded = AdaptiveVariant(referenceSize: Size(1440, 900));

void _setViewport(WidgetTester tester, Size logicalSize, {double dpr = 1}) {
  tester.view.devicePixelRatio = dpr;
  tester.view.physicalSize = logicalSize * dpr;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Widget _app(Widget home, {GlobalKey<NavigatorState>? navigatorKey}) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    builder: (context, child) {
      return AdaptiveDesignScale(
        compact: _compact,
        medium: _medium,
        expanded: _expanded,
        child: child ?? const SizedBox.shrink(),
      );
    },
    home: home,
  );
}

Widget _environment(MediaQueryData data, Widget child) {
  return MediaQuery(
    data: data,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    ),
  );
}

void main() {
  final cases = <Size, AdaptiveWindowClass>{
    Size(375, 812): AdaptiveWindowClass.compact,
    Size(599, 900): AdaptiveWindowClass.compact,
    Size(600, 900): AdaptiveWindowClass.medium,
    Size(800, 1280): AdaptiveWindowClass.medium,
    Size(840, 900): AdaptiveWindowClass.expanded,
    Size(1440, 900): AdaptiveWindowClass.expanded,
  };

  for (final entry in cases.entries) {
    testWidgets('selects ${entry.value.name} before scaling ${entry.key}',
        (tester) async {
      _setViewport(tester, entry.key);
      late AdaptiveScope adaptive;
      late DesignScaleScope scale;
      late MediaQueryData media;
      await tester.pumpWidget(_app(Builder(builder: (context) {
        adaptive = AdaptiveScope.of(context);
        scale = DesignScaleScope.of(context);
        media = MediaQuery.of(context);
        return const SizedBox.shrink();
      })));

      final expectedReference = switch (entry.value) {
        AdaptiveWindowClass.compact => _compact.referenceSize,
        AdaptiveWindowClass.medium => _medium.referenceSize,
        AdaptiveWindowClass.expanded => _expanded.referenceSize,
      };
      expect(adaptive.windowClass, entry.value);
      expect(adaptive.viewportSize, entry.key);
      expect(scale.config.referenceSize, expectedReference);
      expect(media.size, scale.result.virtualSize);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('uses logical pixels rather than device pixels', (tester) async {
    _setViewport(tester, const Size(400, 800), dpr: 3);
    late AdaptiveScope adaptive;
    late MediaQueryData media;
    await tester.pumpWidget(_app(Builder(builder: (context) {
      adaptive = AdaptiveScope.of(context);
      media = MediaQuery.of(context);
      return const SizedBox.shrink();
    })));
    expect(adaptive.windowClass, AdaptiveWindowClass.compact);
    expect(adaptive.viewportSize, const Size(400, 800));
    expect(media.devicePixelRatio, 3);
  });

  testWidgets('fallback changes config, not the measured window class',
      (tester) async {
    _setViewport(tester, const Size(1200, 900));
    late AdaptiveScope adaptive;
    late DesignScaleScope scale;
    final probe = Builder(builder: (context) {
      adaptive = AdaptiveScope.of(context);
      scale = DesignScaleScope.of(context);
      return const SizedBox.shrink();
    });
    Widget host({AdaptiveVariant? medium}) {
      return _environment(
        const MediaQueryData(size: Size(1200, 900)),
        AdaptiveDesignScale(compact: _compact, medium: medium, child: probe),
      );
    }

    await tester.pumpWidget(host(medium: _medium));
    expect(adaptive.windowClass, AdaptiveWindowClass.expanded);
    expect(scale.config.referenceSize, _medium.referenceSize);
    await tester.pumpWidget(host());
    expect(adaptive.windowClass, AdaptiveWindowClass.expanded);
    expect(scale.config.referenceSize, _compact.referenceSize);
  });

  testWidgets('medium config falls back to compact', (tester) async {
    _setViewport(tester, const Size(800, 1280));
    late DesignScaleScope observed;
    await tester.pumpWidget(_environment(
      const MediaQueryData(size: Size(800, 1280)),
      AdaptiveDesignScale(
        compact: _compact,
        child: Builder(builder: (context) {
          observed = DesignScaleScope.of(context);
          return const SizedBox.shrink();
        }),
      ),
    ));
    expect(observed.config.referenceSize, _compact.referenceSize);
  });

  testWidgets('passes the selected variant limits to the existing engine',
      (tester) async {
    _setViewport(tester, const Size(1200, 900));
    late ScaleResult result;
    await tester.pumpWidget(_environment(
      const MediaQueryData(size: Size(1200, 900)),
      AdaptiveDesignScale(
        compact: _compact,
        expanded: const AdaptiveVariant(
          referenceSize: Size(400, 300),
          limits: ScaleLimits(max: 1.25),
        ),
        child: Builder(builder: (context) {
          result = DesignScaleScope.of(context).result;
          return const SizedBox.shrink();
        }),
      ),
    ));
    expect(result.rawScale, 3);
    expect(result.scale, 1.25);
    expect(result.isClamped, isTrue);
  });

  testWidgets('standalone builder installs a scope and runs one branch',
      (tester) async {
    _setViewport(tester, const Size(800, 1280));
    var compactCalls = 0;
    var mediumCalls = 0;
    var expandedCalls = 0;
    await tester.pumpWidget(_environment(
      const MediaQueryData(size: Size(800, 1280)),
      AdaptiveBuilder(
        compact: (_) {
          compactCalls += 1;
          return const SizedBox.shrink();
        },
        medium: (context) {
          mediumCalls += 1;
          const columns =
              AdaptiveValue<int>(compact: 1, medium: 2, expanded: 4);
          return Text('columns: ${columns.resolve(context)}');
        },
        expanded: (_) {
          expandedCalls += 1;
          return const SizedBox.shrink();
        },
      ),
    ));
    expect(compactCalls, 0);
    expect(mediumCalls, 1);
    expect(expandedCalls, 0);
    expect(find.text('columns: 2'), findsOneWidget);
  });

  testWidgets('builder under core scaling uses original, not virtual width',
      (tester) async {
    _setViewport(tester, const Size(800, 1280));
    late double virtualWidth;
    await tester.pumpWidget(_environment(
      const MediaQueryData(size: Size(800, 1280)),
      DesignScale(
        referenceSize: const Size(375, 812),
        child: AdaptiveBuilder(
          compact: (_) => const Text('wrong compact'),
          medium: (context) {
            virtualWidth = MediaQuery.sizeOf(context).width;
            return const Text('medium');
          },
        ),
      ),
    ));
    expect(virtualWidth, lessThan(600));
    expect(find.text('medium'), findsOneWidget);
    expect(find.text('wrong compact'), findsNothing);
  });

  testWidgets('builder inherits custom root breakpoints', (tester) async {
    _setViewport(tester, const Size(500, 900));
    await tester.pumpWidget(_environment(
      const MediaQueryData(size: Size(500, 900)),
      AdaptiveDesignScale(
        compact: _compact,
        medium: _medium,
        breakpoints: const AdaptiveBreakpoints(compactEnd: 400, mediumEnd: 900),
        child: AdaptiveBuilder(
          compact: (_) => const Text('compact'),
          medium: (_) => const Text('medium'),
        ),
      ),
    ));
    expect(find.text('medium'), findsOneWidget);
  });

  testWidgets('builder can explicitly override inherited breakpoints',
      (tester) async {
    _setViewport(tester, const Size(800, 1280));
    await tester.pumpWidget(_app(AdaptiveBuilder(
      breakpoints: const AdaptiveBreakpoints(compactEnd: 900, mediumEnd: 1200),
      compact: (_) => const Text('custom compact'),
      medium: (_) => const Text('medium'),
    )));
    expect(find.text('custom compact'), findsOneWidget);
  });

  testWidgets('absent builders fall back toward compact', (tester) async {
    _setViewport(tester, const Size(1200, 900));
    Widget host({WidgetBuilder? medium}) {
      return _environment(
        const MediaQueryData(size: Size(1200, 900)),
        AdaptiveBuilder(
          compact: (_) => const Text('compact'),
          medium: medium,
        ),
      );
    }

    await tester.pumpWidget(host(medium: (_) => const Text('medium')));
    expect(find.text('medium'), findsOneWidget);
    await tester.pumpWidget(host());
    expect(find.text('compact'), findsOneWidget);
  });

  testWidgets('idle pumping does not repeatedly invoke the selected builder',
      (tester) async {
    _setViewport(tester, const Size(800, 1280));
    var builds = 0;
    await tester.pumpWidget(_app(AdaptiveBuilder(
      compact: (_) => const SizedBox.shrink(),
      medium: (_) {
        builds += 1;
        return const SizedBox.shrink();
      },
    )));
    await tester.pumpAndSettle();
    final settledBuilds = builds;
    for (var i = 0; i < 10; i += 1) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(builds, settledBuilds);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('navigation and route state survive class changes',
      (tester) async {
    _setViewport(tester, const Size(400, 800));
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(_app(
      const Scaffold(body: Text('home route')),
      navigatorKey: navigatorKey,
    ));
    final navigator = navigatorKey.currentState!;
    navigator.push<void>(MaterialPageRoute<void>(
      builder: (_) => const _CounterRoute(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('increment')));
    await tester.pump();

    for (final size in [
      const Size(800, 1280),
      const Size(1440, 900),
      const Size(400, 800),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(navigatorKey.currentState, same(navigator));
      expect(find.text('count: 1'), findsOneWidget);
      expect(navigator.canPop(), isTrue);
    }
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('home route'), findsOneWidget);
  });

  testWidgets('rotation selects by new window width', (tester) async {
    _setViewport(tester, const Size(400, 800));
    late AdaptiveWindowClass observed;
    await tester.pumpWidget(_app(Builder(builder: (context) {
      observed = AdaptiveScope.of(context).windowClass;
      return const SizedBox.shrink();
    })));
    expect(observed, AdaptiveWindowClass.compact);
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();
    expect(observed, AdaptiveWindowClass.medium);
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    expect(observed, AdaptiveWindowClass.compact);
  });

  testWidgets('keyboard insets preserve classification and accessibility',
      (tester) async {
    _setViewport(tester, const Size(800, 1280));
    late MediaQueryData media;
    late AdaptiveScope adaptive;
    late ScaleResult scale;
    final probe = Builder(builder: (context) {
      media = MediaQuery.of(context);
      adaptive = AdaptiveScope.of(context);
      scale = DesignScaleScope.of(context).result;
      return const SizedBox.shrink();
    });
    Widget host(double keyboard) {
      return _environment(
        MediaQueryData(
          size: const Size(800, 1280),
          viewPadding: const EdgeInsets.only(top: 24, bottom: 20),
          padding: EdgeInsets.only(top: 24, bottom: keyboard == 0 ? 20 : 0),
          viewInsets: EdgeInsets.only(bottom: keyboard),
          textScaler: const TextScaler.linear(2),
          highContrast: true,
          boldText: true,
        ),
        AdaptiveDesignScale(
          compact: _compact,
          medium: _medium,
          child: probe,
        ),
      );
    }

    await tester.pumpWidget(host(0));
    final closedScale = scale.scale;
    await tester.pumpWidget(host(300));
    expect(adaptive.windowClass, AdaptiveWindowClass.medium);
    expect(scale.scale, closedScale);
    expect(media.viewInsets.bottom, closeTo(300 / closedScale, 0.00001));
    expect(media.viewPadding.bottom, closeTo(20 / closedScale, 0.00001));
    expect(media.textScaler.scale(16), 32);
    expect(media.highContrast, isTrue);
    expect(media.boldText, isTrue);
    await tester.pumpWidget(host(0));
    expect(media.viewInsets.bottom, 0);
    expect(scale.scale, closedScale);
  });

  testWidgets('missing adaptive scope has an actionable error', (tester) async {
    await tester.pumpWidget(Builder(builder: (context) {
      expect(
        () => AdaptiveScope.of(context),
        throwsA(isA<FlutterError>().having(
          (error) => error.toString(),
          'message',
          contains('No AdaptiveScope'),
        )),
      );
      return const SizedBox.shrink();
    }));
  });

  testWidgets('rejects nested scaling instead of double scaling',
      (tester) async {
    _setViewport(tester, const Size(400, 800));
    await tester.pumpWidget(_environment(
      const MediaQueryData(size: Size(400, 800)),
      const DesignScale(
        referenceSize: Size(400, 800),
        child: AdaptiveDesignScale(
          compact: _compact,
          child: SizedBox.shrink(),
        ),
      ),
    ));
    expect(tester.takeException().toString(), contains('instead of nesting'));
  });

  testWidgets('rejects a partial viewport rather than misplacing window insets',
      (tester) async {
    _setViewport(tester, const Size(800, 1280));
    await tester.pumpWidget(_environment(
      const MediaQueryData(size: Size(800, 1280)),
      const Padding(
        padding: EdgeInsets.all(20),
        child: AdaptiveDesignScale(
          compact: _compact,
          child: SizedBox.shrink(),
        ),
      ),
    ));
    expect(tester.takeException().toString(), contains('must fill'));
  });
}

class _CounterRoute extends StatefulWidget {
  const _CounterRoute();

  @override
  State<_CounterRoute> createState() => _CounterRouteState();
}

class _CounterRouteState extends State<_CounterRoute> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          key: const ValueKey('increment'),
          onPressed: () => setState(() => count += 1),
          child: Text('count: $count'),
        ),
      ),
    );
  }
}
