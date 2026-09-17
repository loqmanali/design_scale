# ADR 0003: Scale calculation uses a policy contract

- Status: Accepted
- Date: 2026-09-17

## Context

There is no single scaling algorithm suitable for every product. Hard-coding the formula in the widget couples policy and rendering.

## Decision

Scale math is represented by the `ScalePolicy` interface. `ContainScalePolicy` is the default. Policies receive immutable `ScaleInput` and return immutable `ScaleResult`.

## Consequences

Alternative policies can be added without modifying the public widget or rendering layer, and policy math can be tested without Flutter widget tests.
