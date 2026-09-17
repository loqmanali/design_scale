import 'package:design_scale/design_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('exposes a virtual MediaQuery and scope below MaterialApp.builder', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    MediaQueryData? observedMediaQuery;
    DesignScaleScope? observedScope;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return DesignScale(
            referenceSize: const Size(400, 800),
            child: Builder(
              builder: (context) {
                observedMediaQuery = MediaQuery.of(context);
                observedScope = DesignScaleScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          );
        },
        home: const SizedBox.shrink(),
      ),
    );

    expect(observedMediaQuery, isNotNull);
    expect(observedMediaQuery!.size, const Size(400, 800));
    expect(observedScope, isNotNull);
    expect(observedScope!.result.scale, 2);
    expect(observedScope!.result.virtualSize, const Size(400, 800));
  });

  testWidgets('accepts an explicit immutable config', (tester) async {
    const config = DesignScaleConfig(referenceSize: Size(400, 800));
    DesignScaleScope? observedScope;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return DesignScale.config(
            config: config,
            child: Builder(
              builder: (context) {
                observedScope = DesignScaleScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          );
        },
        home: const SizedBox.shrink(),
      ),
    );

    expect(observedScope, isNotNull);
    expect(observedScope!.config, config);
  });

  testWidgets('recalculates scale when the viewport changes', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    DesignScaleScope? observedScope;

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return DesignScale(
            referenceSize: const Size(400, 800),
            child: Builder(
              builder: (context) {
                observedScope = DesignScaleScope.of(context);
                return const SizedBox.shrink();
              },
            ),
          );
        },
        home: const SizedBox.shrink(),
      ),
    );

    expect(observedScope!.result.scale, 2);

    tester.view.physicalSize = const Size(600, 1200);
    await tester.pump();

    expect(observedScope!.result.scale, 1.5);
    expect(observedScope!.result.virtualSize, const Size(400, 800));
  });
}
