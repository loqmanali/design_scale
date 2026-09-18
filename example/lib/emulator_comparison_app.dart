import 'package:design_scale/design_scale.dart';
import 'package:flutter/material.dart';

/// A fixed-reference dashboard used to compare ordinary Flutter rendering with
/// the same subtree rendered through [DesignScale].
class EmulatorComparisonApp extends StatelessWidget {
  const EmulatorComparisonApp({
    super.key,
    required this.designScaleEnabled,
  });

  final bool designScaleEnabled;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'design_scale emulator comparison',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B5BD6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F3F8),
        useMaterial3: true,
      ),
      builder: (context, child) {
        final app = child ?? const SizedBox.shrink();
        if (!designScaleEnabled) {
          return app;
        }

        return DesignScale(
          referenceSize: const Size(375, 812),
          child: app,
        );
      },
      home: _ComparisonScreen(
        designScaleEnabled: designScaleEnabled,
      ),
    );
  }
}

class _ComparisonScreen extends StatelessWidget {
  const _ComparisonScreen({required this.designScaleEnabled});

  final bool designScaleEnabled;

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final scope = designScaleEnabled ? DesignScaleScope.of(context) : null;
    final modeTitle = designScaleEnabled
        ? 'WITH design_scale'
        : 'WITHOUT design_scale';
    final geometryText = designScaleEnabled
        ? 'Virtual ${_formatSize(mediaSize)}  •  Scale ${scope!.result.scale.toStringAsFixed(2)}×'
        : 'Viewport ${_formatSize(mediaSize)}  •  Scale 1.00×';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 343,
            height: 720,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x240E153A),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(modeTitle: modeTitle),
                    const SizedBox(height: 12),
                    _GeometryBadge(text: geometryText),
                    const SizedBox(height: 14),
                    const _HeroCard(),
                    const SizedBox(height: 14),
                    const Text(
                      'Today at a glance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF171A2B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.bolt_rounded,
                            value: '84%',
                            label: 'Energy',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.timer_outlined,
                            value: '4h 20m',
                            label: 'Focused',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.check_circle_outline_rounded,
                            value: '12',
                            label: 'Tasks',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _InsightCard(),
                    const Spacer(),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text(
                          'Start next focus session',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Authored for a 375 × 812 reference frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF73778E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatSize(Size size) {
    return '${size.width.round()}×${size.height.round()}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.modeTitle});

  final String modeTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF706CF6), Color(0xFF4A46C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FocusFlow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171A2B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                modeTitle,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: Color(0xFF6A6E84),
                ),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 19,
          backgroundColor: Color(0xFFE8E8FF),
          child: Text(
            'L',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A46C7),
            ),
          ),
        ),
      ],
    );
  }
}

class _GeometryBadge extends StatelessWidget {
  const _GeometryBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4A46C7),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF25294B), Color(0xFF434986)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Daily momentum',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC7C9E8),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '72%',
                  style: TextStyle(
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'You are 3 tasks away from today’s goal.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFFD6D8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 82,
            height: 82,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.72,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withOpacity(0.16),
                  color: const Color(0xFF9FF0D0),
                ),
                const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5B5BD6)),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF171A2B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF73778E),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5DE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFFFE2A3),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF8A5A00),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Best focus window',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5C4210),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Your strongest sessions start between 9:00 and 11:00.',
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.3,
                    color: Color(0xFF765B27),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
