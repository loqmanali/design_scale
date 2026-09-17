import 'package:design_scale/design_scale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('benchmark repeated viewport changes', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignScale(
            referenceSize: Size(400, 800),
            child: _BenchmarkTree(),
          ),
        ),
      ),
    );

    final stopwatch = Stopwatch()..start();

    for (var index = 0; index < 200; index += 1) {
      final width = index.isEven ? 400.0 : 800.0;
      final height = index.isEven ? 800.0 : 400.0;
      tester.view.physicalSize = Size(width, height);
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: Size(width, height)),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: DesignScale(
              referenceSize: Size(400, 800),
              child: _BenchmarkTree(),
            ),
          ),
        ),
      );
    }

    stopwatch.stop();
    debugPrint(
      'design_scale viewport benchmark: '
      '${stopwatch.elapsedMicroseconds} µs / 200 rebuilds',
    );
  });
}

final class _BenchmarkTree extends StatelessWidget {
  const _BenchmarkTree();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 100,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 48,
            child: Text('Benchmark row $index'),
          ),
        );
      },
    );
  }
}
