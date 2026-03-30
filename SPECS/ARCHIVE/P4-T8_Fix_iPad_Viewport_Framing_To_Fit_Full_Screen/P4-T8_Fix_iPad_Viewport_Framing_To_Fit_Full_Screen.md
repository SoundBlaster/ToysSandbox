# P4-T8 — Fix iPad Viewport Framing To Fit Full Screen

## Context

On physical iPad devices, the sandbox world appears framed like a fixed 16:9 viewport instead of adapting to the real device aspect ratio. This causes visible unused space and inconsistent world framing.

## Objective

Make sandbox framing responsive to runtime viewport size so the world, camera, background, and collision bounds adapt to portrait and landscape ratios on iPad and to desktop window resizing.

## Dependencies

- P2-T1
- P4-T3

## Deliverables

- Runtime viewport layout update path in sandbox gameplay scene logic.
- Dynamic world bounds updates (floor and side walls) on viewport size changes.
- Camera recentering and play-area clamp updates based on live viewport dimensions.
- Validation report with quality-gate outputs and manual viewport resize checks.

## Implementation Plan

1. Add viewport-responsive layout constants and runtime state in Sandbox logic.
2. Replace fixed play-area rectangle usage with computed runtime rectangle.
3. Update background size, camera position, floor shape/position, and wall shape/position from viewport size.
4. Hook viewport `size_changed` signal and re-apply layout on startup and resize.
5. Preserve existing interaction behavior and input alignment by keeping world-space conversion path unchanged.

## Acceptance Criteria

- On physical iPad, sandbox fills screen area without unintended 16:9 letterbox framing.
- Camera, world bounds, and shelf/menu layout adapt in both portrait and landscape.
- Desktop window resize keeps framing responsive and pointer-to-world interactions aligned.
- Validation includes reproducible resize protocol and recorded outcome.

## Risks And Mitigations

- Risk: Collision shapes could desync from visual background after resize.
  - Mitigation: Update positions and shape sizes in one layout method invoked on startup and resize.
- Risk: Spawn/drag clamp could allow off-screen placement.
  - Mitigation: Clamp against computed runtime play area with safe minimum dimensions.
