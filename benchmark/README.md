# Benchmarks

The benchmark harness is intentionally non-gating because wall-clock timings on shared CI runners are noisy.

Run locally with:

```bash
flutter test benchmark/design_scale_benchmark_test.dart
```

Record Flutter version, platform, device/CPU, build mode, and the reported elapsed time when comparing changes.

The current harness stresses repeated portrait/landscape viewport changes over a 100-row widget tree. Future performance regressions should add a targeted scenario rather than introducing an arbitrary CI timing threshold.
