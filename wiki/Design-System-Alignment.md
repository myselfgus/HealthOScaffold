# Design System Alignment

> HealthOS presentation should feel calm, native, precise, and juridically legible. The design system exists to reveal governed state, not to decorate or obscure it.

---

## Design posture

HealthOS targets a native macOS 26+ presentation baseline with Liquid Glass, SF Pro, semantic tint, high legibility, and disciplined hierarchy.

The interface should communicate:

- legal state;
- clinical state;
- draft vs. final status;
- degraded or unavailable capabilities;
- provenance and audit context;
- consent and habilitation posture;
- gate requirements before clinical effectuation.

Presentation never becomes Core Law. UI reveals law; it does not create law.

---

## Visual principles

| Principle | Meaning |
| :--- | :--- |
| Calm authority | The interface should feel stable, not flashy. |
| Juridical legibility | Users must understand whether an action is draft, gated, final, denied, degraded, or audited. |
| Native materiality | Prefer native macOS conventions and Liquid Glass-compatible spatial structure. |
| Semantic restraint | Use color to communicate meaning, not decoration. |
| Progressive disclosure | Expose complexity when needed; avoid overwhelming first-read surfaces. |
| Evidence-first UI | Clinical claims should point to provenance, source, or audit trail when appropriate. |
| Fail-closed visibility | Denial and unavailability should be explicit, not hidden as generic errors. |

---

## HealthOS tone in interface copy

Use language that is:

- precise;
- calm;
- legally clear;
- clinically respectful;
- explicit about limitations;
- honest about automation and AI.

Avoid language that is:

- magical;
- overconfident;
- consumer-app casual in clinical moments;
- vague about finality;
- ambiguous about whether content is draft or official.

---

## Status language

Prefer explicit state labels:

| State | Preferred language |
| :--- | :--- |
| Draft | `Draft`, `Prepared draft`, `Not finalized` |
| Awaiting gate | `Gate required`, `Awaiting professional review` |
| Approved | `Approved by gate`, `Finalized` |
| Rejected | `Withheld`, `Rejected at gate` |
| Degraded | `Degraded mode`, `Capability limited` |
| Unavailable | `Unavailable`, `Provider unavailable` |
| Denied | `Denied by policy`, `Lawful context missing` |
| Audited | `Audit recorded`, `Provenance attached` |

---

## Layout guidance

A HealthOS screen should usually include:

1. Primary clinical or operational object.
2. Current governance state.
3. Available actions.
4. Gate/finality status when relevant.
5. Provenance or audit access.
6. Degraded/unavailable indicators when relevant.

Do not bury legal state behind secondary menus if it changes user authority or clinical effectuation.

---

## Cards and surfaces

Use card-like surfaces for bounded work units:

| Surface | Good use |
| :--- | :--- |
| Session card | Current clinical session, capture state, consent, habilitation, gate status. |
| Artifact card | Draft/final document with provenance. |
| Capability card | Available runtime or provider capability, including degraded/unavailable posture. |
| Stage card | Stage-specific task or workflow under Boundary mediation. |
| Audit card | Event trail, source, actor, lawful context, timestamp. |

Cards should not imply authority. Authority comes from Core and Boundary state.

---

## Color and semantic tint

Use semantic tint sparingly:

| Meaning | Direction |
| :--- | :--- |
| Approved / valid | Quiet positive state, not celebratory. |
| Warning / degraded | Visible but not alarming unless clinical risk exists. |
| Denied / blocked | Clear and unambiguous. |
| Draft / neutral | Calm neutral surface. |
| AI-generated | Distinguishable from human-finalized content. |

Avoid using decorative gradients or brand color where semantic state is more important.

---

## AI presentation rules

AI output must remain clearly labeled according to maturity and clinical status.

Do:

- label AI-generated drafts;
- show source/provenance when available;
- require professional gate for final effectuation;
- reveal unavailable/degraded provider states;
- avoid finality language before approval.

Do not:

- present generated content as official by default;
- hide uncertainty;
- merge retrieval context and model generation without provenance;
- allow UI copy to imply autonomous clinical authority.

---

## Wiki design convention

The Wiki follows the HealthOS design spirit using GitHub Markdown constraints:

- centered logo on Home;
- badge-based status only where useful;
- short doctrine blocks;
- tables for capability and maturity comparison;
- restrained headings;
- clear canonical-source reminders;
- no ornamental complexity that reduces legibility.

---

## Design system rule

> A beautiful HealthOS interface is not one that looks futuristic. It is one that makes governed clinical action impossible to misunderstand.
