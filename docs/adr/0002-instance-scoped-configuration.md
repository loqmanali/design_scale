# ADR 0002: Configuration is instance-scoped

- Status: Accepted
- Date: 2026-09-17

## Context

A mutable static reference size makes tests order-dependent and prevents independent windows/subtrees from using different design spaces.

## Decision

Reference size, policy, and limits are provided to each `DesignScale` instance. The package has no mutable global configuration.

## Consequences

Multiple scaled subtrees can coexist safely, tests are isolated, and future multi-window support does not depend on process-wide state.
