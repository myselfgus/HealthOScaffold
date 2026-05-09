# Skill: SwiftUI Performance

## Overview
Use this skill to diagnose SwiftUI performance issues from code first, then request profiling evidence when code review alone cannot explain the symptoms.

## Workflow
1. **Classify the symptom**: slow rendering, janky scrolling, high CPU, etc.
2. **Code-First Review**: Use `references/code-smells.md`.
3. **Profiling Intake**: If inconclusive, guide through profiling via `references/profiling-intake.md`.
4. **Remediate**: Apply targeted fixes (narrow state scope, stabilize identity, reduce main-thread work).
5. **Verify**: Compare before/after metrics.

## Focus Areas
- Invalidation storms.
- Unstable identity in lists (`ForEach`).
- Heavy derived work in `body`.
- Layout thrash.
- Large image decoding on main thread.
