/// Layout classes based on available window width, not device hardware.
enum AdaptiveWindowClass {
  /// Width below the configured compact boundary.
  compact,

  /// Width from the compact boundary up to the medium boundary.
  medium,

  /// Width at or above the configured medium boundary.
  expanded,
}
