import 'package:design_scale/design_scale.dart';
import 'package:design_scale/design_scale_debug.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return DesignScale(
          referenceSize: const Size(375, 812),
          child: DesignScaleDebugOverlay(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('design_scale example')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useWideLayout = constraints.maxWidth >= 700;

            if (useWideLayout) {
              return const Row(
                children: [
                  _ExampleRail(),
                  VerticalDivider(width: 1),
                  Expanded(child: _ExampleContent()),
                ],
              );
            }

            return const _ExampleContent();
          },
        ),
      ),
    );
  }
}

class _ExampleRail extends StatelessWidget {
  const _ExampleRail();

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: 0,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Overview'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.tune_outlined),
          selectedIcon: Icon(Icons.tune),
          label: Text('Settings'),
        ),
      ],
    );
  }
}

class _ExampleContent extends StatelessWidget {
  const _ExampleContent();

  @override
  Widget build(BuildContext context) {
    final scale = DesignScaleScope.of(context).result;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Reference-based design space',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Physical ${_formatSize(scale.viewportSize)} → '
          'virtual ${_formatSize(scale.virtualSize)}',
        ),
        const SizedBox(height: 24),
        const _DemoCard(
          title: 'Normal Flutter dimensions',
          description:
              'This card uses ordinary padding, radius, icon, and font values. '
              'No .w, .h, .sp, or .r extensions are needed.',
        ),
        const SizedBox(height: 16),
        const _DemoCard(
          title: 'Adaptive composition stays native',
          description:
              'Resize or rotate the window. LayoutBuilder decides when to show '
              'the navigation rail; design_scale only owns uniform scaling.',
        ),
        const SizedBox(height: 24),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Open the keyboard',
            helperText: 'Keyboard insets remain in virtual coordinates.',
          ),
        ),
      ],
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}

String _formatSize(Size size) {
  return '${size.width.toStringAsFixed(0)}×${size.height.toStringAsFixed(0)}';
}
