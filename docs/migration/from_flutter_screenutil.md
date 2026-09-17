# Migrating from flutter_screenutil

`design_scale` is designed for teams that want to author ordinary Flutter dimensions inside a reference design space instead of annotating individual values with scaling extensions.

## Before

```dart
Container(
  width: 120.w,
  height: 48.h,
  padding: EdgeInsets.all(16.w),
  child: Text(
    'Continue',
    style: TextStyle(fontSize: 16.sp),
  ),
)
```

## After

Configure the design reference once:

```dart
MaterialApp(
  builder: (context, child) {
    return DesignScale(
      referenceSize: const Size(375, 812),
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

Then keep authored dimensions unchanged:

```dart
Container(
  width: 120,
  height: 48,
  padding: const EdgeInsets.all(16),
  child: const Text(
    'Continue',
    style: TextStyle(fontSize: 16),
  ),
)
```

## Important differences

- `design_scale` applies one uniform scale to the whole design coordinate system.
- Width and height are never scaled independently.
- Font sizes still respect Flutter's `TextScaler` and user accessibility preferences.
- Responsive/adaptive composition remains the application's responsibility through `LayoutBuilder`, breakpoints, and platform-appropriate navigation patterns.
- Use `ScaleLimits` only when the product explicitly needs bounds on global scaling; do not use it to replace adaptive layouts.
