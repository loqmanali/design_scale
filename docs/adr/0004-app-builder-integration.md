# ADR 0004: Integrate through the app builder

- Status: Accepted
- Date: 2026-09-17

## Context

Wrapping `MaterialApp` from the outside is unreliable because the app creates its own `MediaQuery` for descendants. A scaling package that needs to transform viewport metrics must operate below that boundary.

## Decision

The documented integration point is `MaterialApp.builder`, `CupertinoApp.builder`, or an equivalent location that already has the app's current `MediaQuery`.

## Consequences

`DesignScale` consumes authoritative window metrics and its transformed `MediaQuery` reaches the navigator/overlay subtree. Attempting to use it without a `MediaQuery` fails with an actionable error.
