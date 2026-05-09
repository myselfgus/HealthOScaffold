# Developer Onboarding

> This page gives a practical path for entering the repository without violating the HealthOS architecture.

---

## Prerequisites

| Tool | Expected version | Purpose |
| :--- | :--- | :--- |
| macOS | 26+ | Target platform and native app baseline. |
| Xcode | 26+ | Workspace, schemes, previews, and Swift tooling. |
| Swift / SwiftPM | 6.2+ | Platform package build and tests. |
| Node.js | LTS 20+ | TypeScript workspace. |
| pnpm | 9+ | TypeScript package manager. |
| Python | 3.11+ | Support ML and governance scaffolds where applicable. |

---

## First read

Before editing code, read:

1. `README.md`
2. `HealthOS/Shared/docs/architecture/01-overview.md`
3. `HealthOS/Package.swift`
4. `HealthOS/Shared/docs/execution/11-current-maturity-map.md`
5. The tests for the module you intend to modify.

---

## Clone and inspect

```bash
git clone https://github.com/myselfgus/HealthOScaffold.git
cd HealthOScaffold
```

Inspect the top-level architecture:

```bash
ls
ls HealthOS
sed -n '1,220p' HealthOS/Package.swift
```

---

## Swift platform package

The central platform package is under `HealthOS/Package.swift`.

```bash
cd HealthOS
swift package describe
swift build
swift test
```

If your macOS/Xcode/Swift toolchain does not support the declared platform and tools version, do not lower the project requirement casually. The macOS 26+ posture is part of the product and design baseline.

---

## Stage packages

Tier 4 Stages are intentionally separate from the central platform package.

Typical inspection path:

```bash
find HealthOS/Tier4-Stages-Cast -name Package.swift -maxdepth 3 -print
```

Before editing a Stage, confirm that it consumes `HealthOSBoundary` and `CustomSDK` rather than importing Tier 2 runtime modules directly.

---

## TypeScript workspace

The TypeScript workspace lives under `HealthOS/Constructor/ts/`.

```bash
cd HealthOS/Constructor/ts
pnpm install
pnpm test
pnpm build
```

Use this area for contracts, GOS tooling, Construction System tooling, Steward, forge MCP, and related repository-maintenance surfaces. Do not treat it as clinical runtime authority.

---

## Python and Support tooling

Support tooling lives under `HealthOS/Support/`.

It may assist Core, runtimes, Stages, and Constructor workflows, but its usage remains governed by Core law and ModelGovernance.

Do not import Support as a runtime authority module. `HealthOSProviders` is the Swift runtime provider-adapter target.

---

## Contribution rules by layer

| Layer | Before you edit | Required care |
| :--- | :--- | :--- |
| Tier 1 — Core | Read governance tests and canonical docs. | Preserve fail-closed behavior and update tests. |
| Tier 2 — Runtimes | Identify which Core invariant governs the runtime action. | Prove denial/degraded paths. |
| Tier 3 — Boundary | Confirm Stage consumption rules. | Avoid exposing Tier 1/Tier 2 internals. |
| Tier 4 — Stages | Confirm Custom readiness and Boundary availability. | UI must not invent authority. |
| Constructor | Confirm it remains repo-maintenance only. | Do not create clinical/runtime authority from construction tooling. |
| Support | Confirm Core governance and provider posture. | Do not bypass ModelGovernance or provider fail-closed policy. |

---

## PR checklist

Every meaningful PR should answer:

- Which Tier or repository domain does this touch?
- Does this alter Core Law, consent, habilitation, finality, provenance, audit, or lawful context?
- Does this expose a runtime surface to Stage code?
- Does this change maturity claims?
- Were tests added or updated?
- Were canonical docs updated if doctrine changed?
- Does degraded/unavailable behavior remain explicit?
- Does AI/provider behavior remain fail-closed where required?

---

## Local validation posture

Prefer repository-provided validation scripts when available. If validation is partial, state exactly what was run and what remains unverified.

Do not use “build passed” as a substitute for architecture compliance. HealthOS correctness includes governance behavior, denial paths, maturity language, and documentation alignment.

---

## Common mistakes

| Mistake | Why it is wrong |
| :--- | :--- |
| Importing runtime modules directly into Stage apps | Violates Boundary-first consumption. |
| Treating AI output as final clinical artifact | Violates gate/finality doctrine. |
| Adding provider behavior without degraded/unavailable state | Weakens honest model posture. |
| Updating Wiki but not canonical docs | Creates divergence from source of truth. |
| Treating Constructor as runtime law | Confuses repository maintenance with clinical authority. |
| Hiding legal state behind UI polish | Violates HealthOS presentation intent. |

---

## Minimal safe contribution path

1. Pick a narrow module.
2. Read its tests and docs.
3. Make the smallest change consistent with the Tier boundary.
4. Add or update tests.
5. Update canonical docs if behavior or doctrine changed.
6. Update Wiki only if onboarding or public explanation should change.
7. In the PR, state maturity impact explicitly.
