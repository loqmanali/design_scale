import 'package:design_scale/design_scale.dart';
import 'package:flutter/material.dart';

class ComparisonApp extends StatelessWidget {
  const ComparisonApp({
    super.key,
    required this.useDesignScale,
  });

  final bool useDesignScale;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF3156D3),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'design_scale comparison',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();

        if (!useDesignScale) {
          return content;
        }

        return DesignScale(
          referenceSize: const Size(375, 812),
          child: content,
        );
      },
      home: ComparisonHomePage(useDesignScale: useDesignScale),
    );
  }
}

class ComparisonHomePage extends StatelessWidget {
  const ComparisonHomePage({
    super.key,
    required this.useDesignScale,
  });

  final bool useDesignScale;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaleResult = useDesignScale
        ? DesignScaleScope.of(context).result
        : null;
    final physicalSize = scaleResult?.viewportSize ?? mediaQuery.size;
    final layoutSize = scaleResult?.virtualSize ?? mediaQuery.size;
    final scale = scaleResult?.scale ?? 1.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('design_scale comparison'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: useDesignScale
                      ? const Color(0xFFE3F6EA)
                      : const Color(0xFFFFE7E2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  useDesignScale
                      ? 'AFTER · WITH DESIGN_SCALE'
                      : 'BEFORE · WITHOUT DESIGN_SCALE',
                  style: TextStyle(
                    color: useDesignScale
                        ? const Color(0xFF166534)
                        : const Color(0xFF9A3412),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'One design frame.\nDifferent viewport.',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Every component below uses ordinary Flutter numbers authored '
              'for a 375 × 812 reference frame.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5B6475),
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 20),
            _MetricsCard(
              physicalSize: physicalSize,
              layoutSize: layoutSize,
              scale: scale,
            ),
            const SizedBox(height: 16),
            Container(
              height: 128,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3156D3), Color(0xFF6484F3)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x263156D3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fixed design values',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '20 padding · 20 radius · 52 icon box',
                          style: TextStyle(
                            color: Color(0xFFE8EDFF),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: _StatTile(value: '24', label: 'Padding')),
                SizedBox(width: 8),
                Expanded(child: _StatTile(value: '16', label: 'Radius')),
                SizedBox(width: 8),
                Expanded(child: _StatTile(value: '48', label: 'Button')),
              ],
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email address',
                hintText: 'hello@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue'),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              height: 12,
              width: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '300 design pixels',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({
    required this.physicalSize,
    required this.layoutSize,
    required this.scale,
  });

  final Size physicalSize;
  final Size layoutSize;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MetricRow(
              label: 'Physical viewport',
              value: _formatSize(physicalSize),
            ),
            const Divider(height: 20),
            _MetricRow(
              label: 'Layout viewport',
              value: _formatSize(layoutSize),
            ),
            const Divider(height: 20),
            _MetricRow(
              label: 'Applied scale',
              value: '${scale.toStringAsFixed(3)}×',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF3156D3),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatSize(Size size) {
  return '${size.width.toStringAsFixed(0)} × ${size.height.toStringAsFixed(0)}';
}
