# ADR-0007: Test the minimum and current stable Flutter versions

- **Status:** Accepted
- **Date:** 2026-09-17

## Context

The package declares Flutter `>=3.19.0`, but testing only the newest stable SDK
does not verify that promise. Conversely, testing only the minimum version would
miss compatibility problems introduced by current framework changes.

Rendering, semantics, `MediaQuery`, and test APIs are all framework-sensitive
areas.

## Decision

CI runs the full analyzer and test suite twice:

1. Flutter 3.19.0, the declared minimum supported release;
2. the current stable Flutter channel.

Development dependencies use version ranges that can resolve on both supported
SDKs.

## Consequences

### Positive

- The package's minimum-version claim is continuously verified.
- Framework regressions on the current stable channel are detected early.
- Rendering and accessibility behavior is checked at both ends of the support
  window.

### Trade-offs

- CI time and cache storage increase.
- New language or framework APIs cannot be adopted without either a compatible
  fallback or an explicit minimum-version change.
