import 'package:design_scale/src/rendering/design_scale_viewport.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lays out the child in virtual coordinates', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final childKey = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DesignScaleViewport(
          scale: 2,
          virtualSize: const Size(400, 800),
          child: SizedBox(key: childKey),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(childKey)), const Size(400, 800));
  });

  testWidgets('applies the same transform to coordinate conversion', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final childKey = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DesignScaleViewport(
          scale: 2,
          virtualSize: const Size(400, 800),
          child: SizedBox(key: childKey),
        ),
      ),
    );

    final child = tester.renderObject<RenderBox>(find.byKey(childKey));
    expect(
      child.localToGlobal(const Offset(50, 60)),
      const Offset(100, 120),
    );
  });

  testWidgets('inverse-transforms pointer positions during hit testing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var tapCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DesignScaleViewport(
          scale: 2,
          virtualSize: const Size(400, 800),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 30,
                width: 40,
                height: 50,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => tapCount += 1,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tapAt(const Offset(80, 100));
    await tester.pump();
    expect(tapCount, 1);

    await tester.tapAt(const Offset(140, 100));
    await tester.pump();
    expect(tapCount, 1);
  });

  testWidgets('applies the viewport transform to semantic bounds', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final semanticsHandle = tester.ensureSemantics();
    addTearDown(semanticsHandle.dispose);

    final semanticsKey = GlobalKey();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DesignScaleViewport(
          scale: 2,
          virtualSize: const Size(400, 800),
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 30,
                width: 40,
                height: 50,
                child: Semantics(
                  key: semanticsKey,
                  container: true,
                  label: 'Scaled target',
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final node = tester.getSemantics(find.byKey(semanticsKey));
    expect(node.label, 'Scaled target');
    expect(
      _semanticRectInRoot(node),
      const Rect.fromLTWH(40, 60, 80, 100),
    );
  });

  testWidgets('updates layout and paint transforms when scale changes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final childKey = GlobalKey();

    Widget build(double scale) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: DesignScaleViewport(
          scale: scale,
          virtualSize: Size(800 / scale, 1600 / scale),
          child: SizedBox(key: childKey),
        ),
      );
    }

    await tester.pumpWidget(build(1));
    var child = tester.renderObject<RenderBox>(find.byKey(childKey));
    expect(child.localToGlobal(const Offset(50, 60)), const Offset(50, 60));

    await tester.pumpWidget(build(2));
    child = tester.renderObject<RenderBox>(find.byKey(childKey));
    expect(child.localToGlobal(const Offset(50, 60)), const Offset(100, 120));
    expect(child.size, const Size(400, 800));
  });

  test('rejects invalid scale and virtual size values', () {
    expect(
      () => RenderDesignScaleViewport(
        scale: 0,
        virtualSize: const Size(400, 800),
      ),
      throwsArgumentError,
    );

    expect(
      () => RenderDesignScaleViewport(
        scale: 1,
        virtualSize: Size.zero,
      ),
      throwsArgumentError,
    );
  });
}

Rect _semanticRectInRoot(SemanticsNode node) {
  final transforms = <Matrix4>[];
  SemanticsNode? current = node;

  while (current != null) {
    final transform = current.transform;
    if (transform != null) {
      transforms.add(transform);
    }
    current = current.parent;
  }

  final transformToRoot = Matrix4.identity();
  for (final transform in transforms.reversed) {
    transformToRoot.multiply(transform);
  }

  return MatrixUtils.transformRect(transformToRoot, node.rect);
}
