import 'package:design_scale/design_scale_adaptive.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AdaptiveDemoApp());

/// Optional adaptive example; the original example entrypoint is unchanged.
class AdaptiveDemoApp extends StatelessWidget {
  const AdaptiveDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive design_scale',
      builder: (context, child) {
        return AdaptiveDesignScale(
          compact: const AdaptiveVariant(referenceSize: Size(375, 812)),
          medium: const AdaptiveVariant(referenceSize: Size(768, 1024)),
          expanded: const AdaptiveVariant(referenceSize: Size(1440, 900)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _Dashboard(),
    );
  }
}

class _Dashboard extends StatefulWidget {
  const _Dashboard();

  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  // Shared state is owned ABOVE the layout variants.
  final _notes = TextEditingController();
  int _selectedIndex = 0;
  int _count = 0;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      compact: (context) => _page(context, AdaptiveWindowClass.compact),
      medium: (context) => _page(context, AdaptiveWindowClass.medium),
      expanded: (context) => _page(context, AdaptiveWindowClass.expanded),
    );
  }

  Widget _page(BuildContext context, AdaptiveWindowClass windowClass) {
    final adaptive = AdaptiveScope.of(context);
    final compact = windowClass == AdaptiveWindowClass.compact;
    const columnChoices = AdaptiveValue<int>(
      compact: 1,
      medium: 2,
      expanded: 3,
    );
    final columns = columnChoices.resolve(context);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Layout: ${windowClass.name}'),
          const SizedBox(height: 8),
          Text('Unscaled window: ${adaptive.viewportSize}'),
          Text('Virtual space: ${MediaQuery.sizeOf(context)}'),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2,
            children: List.generate(3, (index) {
              return Card(
                child: Center(child: Text('Panel ${index + 1}')),
              );
            }),
          ),
          const SizedBox(height: 24),
          TextField(
            key: const ValueKey('adaptive-notes'),
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Persistent notes'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('adaptive-increment'),
            onPressed: () => setState(() => _count += 1),
            child: Text('Count: $_count'),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Adaptive design_scale')),
      body: SafeArea(
        child: Row(
          children: [
            if (!compact)
              NavigationRail(
                extended: windowClass == AdaptiveWindowClass.expanded,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _select,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    label: Text('Overview'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    label: Text('Settings'),
                  ),
                ],
              ),
            Expanded(
              key: const ValueKey('adaptive-content'),
              child: content,
            ),
          ],
        ),
      ),
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
            )
          : null,
    );
  }
}
