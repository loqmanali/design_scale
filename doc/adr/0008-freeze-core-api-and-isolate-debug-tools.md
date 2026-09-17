# ADR-0008: Freeze the core API and isolate debug tools

- **Status:** Accepted
- **Date:** 2026-09-17

## Context

The scaling engine, render viewport, window geometry transformation, semantics, and compatibility matrix are now implemented. Before a release candidate, the package needs a stable import surface that can evolve under semantic versioning without exposing rendering or diagnostic implementation details.

Diagnostics are useful during adoption, but adding debug UI to the primary package barrel would expand the core contract and make future changes harder.

## Decision

1. Freeze the release-candidate core barrel at `package:design_scale/design_scale.dart` to the scaling API only.
2. Keep rendering, MediaQuery, and geometry adapters private under `lib/src`.
3. Publish debug helpers through the secondary library `package:design_scale/design_scale_debug.dart`.
4. Keep the debug overlay inactive in profile and release builds.
5. Document the intended compatibility promise in `docs/public-api.md`.
6. Use the `0.1.0-rc.x` series for real-app validation before a `1.0.0` semantic-versioning guarantee.

## Consequences

### Positive

- The common import stays small and focused.
- Internal rendering and geometry implementation can evolve without breaking consumers.
- Diagnostics remain discoverable without becoming a core dependency surface.
- The package can collect release-candidate feedback before committing to `1.0.0` compatibility.

### Trade-offs

- Consumers wanting diagnostics need a second import.
- The release candidate intentionally avoids adding new scale policies until the policy contract is validated in real applications.
