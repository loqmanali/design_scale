import 'package:flutter/widgets.dart';

import 'emulator_comparison_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const EmulatorComparisonApp(
      designScaleEnabled: true,
    ),
  );
}
