# SKILL.md — HealthOS design system

When the user is designing for **HealthOS**, **Scribe**, **Veridia**, or **CloudClinic**, follow this skill.

---

## Read these first
1. `README.md` — overview, philosophy, foundations.
2. `colors_and_type.css` — every color, font, space, radius, shadow, capsule, glass material.
3. The relevant `ui_kits/<product>/` README + `index.html` if it exists.

---

## Core mental model

**HealthOS is a sovereign computational environment, not a SaaS product.** The architecture splits into:

| Layer | Where it lives | Surface treatment |
|:---|:---|:---|
| **HealthOS Core** | The Mac. Source of clinical and computational law. | Sovereign — primary brand color (#3B4A6B). |
| **Scribe** | macOS 26+ professional clinical workspace. | Sovereign + active states. |
| **Veridia** | macOS patient health identity surface (mediated). | Mediated (#0E7C86). Bounded. Never effectuates. |
| **CloudClinic** | macOS/web service-operations console. | Mediated. Non-clinical. |

**The law is in HealthOS, not in surfaces.** Every surface is bounded; effectuation always passes through documented gates.

---

## Visual decisions — non-negotiable

- **Aesthetic:** macOS 26+ Liquid Glass. Use the `glass-thin / glass-regular / glass-thick` classes for layered surfaces. Soft, generous corner radii (8–16px). Hairline borders (0.5px). Cards float on subtly tinted backgrounds.
- **Typography:** SF Pro Display for headings, SF Pro Text for UI/body, SF Mono for transcripts/tokens/identifiers. Use the `--type-*` and `t-*` utility classes — never hardcode sizes.
- **Color discipline:** brand accents are **Sovereign #3B4A6B** and **Mediated #0E7C86**, used semantically (sovereign = HealthOS-side, mediated = bridge/civil). Reach for accents only when they carry meaning. Neutrals do most of the work.
- **State colors are a typed alphabet.** Always pull from `--state-*` tokens. Use the `<span class="capsule" data-state="...">` component for any status pill — every state has a predefined background + foreground.
  - `ready · active · degraded · denied · failed · pending · final · withheld · info`
- **Spacing:** 8-pt rhythm. Use `--space-*` tokens. Reading width in cards: ~640–760px max.
- **Shadows:** three tiers only — `--shadow-recess` (inputs), `--shadow-card` (resting), `--shadow-floating` (popover/sheet). Never invent.

---

## Content discipline

The product surfaces honest, scaffold-stage state:

- Use **disposition-style language**: `partial_success`, `governed_deny`, `awaiting_gate`, `withheld`, not "Success!" or "Oops!".
- Banners that name what the system did and didn't do, calmly. No alarms, no rewards, no toasts that disappear.
- Bilingual is normal: medical content in **PT-BR** is realistic for this product. UI chrome stays in English.
- Identifiers, tokens, transcripts, audit lines → **monospace**.
- Never invent stats, KPIs, or marketing copy. If you need filler, ask.
- No emoji. No animated gradients. No Inter, Roboto, or generic SaaS chrome.

---

## When designing

1. **Identify the surface.** Which product? Which actor? (professional / civil / operator).
2. **Identify the action's classification.** Is it sovereign (effectuates), mediated (reads/transports under consent), or governed (gated)? Color, capsule, and copy follow.
3. **Use the kit components.** Capsule, Banner, GlassCard, OutputBlock, GatePanel, Button — they exist; reach for them before inventing.
4. **Show real state plumbing.** Capture, transcription, retrieval, draft, gate, final document — every screen should make the slice visible. The user values seeing the machinery.
5. **Variations explore content rhythm and visual weight, not chrome.** When asked for tweaks, vary density, glass tier, capsule emphasis, or section ordering — not the color system.

---

## Asset locations

```
assets/
  healthos-mark.svg      ← primary brand mark
  glyph-scribe.svg       ← professional surface app glyph
  glyph-veridia.svg      ← patient health identity surface app glyph
  glyph-cloudclinic.svg  ← service-ops surface app glyph
colors_and_type.css      ← every token. Import with @import or <link>.
ui_kits/scribe/          ← React components + click-thru of the implemented Scribe surface.
ui_kits/veridia/         ← Documented surface, no Swift implementation yet. (formerly ui_kits/sortio/)
ui_kits/cloudclinic/     ← Documented surface, no Swift implementation yet.
preview/                 ← Static preview cards, one per token group.
```

---

## What NOT to do

- Don't add marketing pages, hero sections, "Built with confidence" copy, or feature taglines.
- Don't introduce new colors without grounding them in the `--hos-*` or `--state-*` system.
- Don't draw clinical iconography in SVG from scratch — use SF Symbols substitutes (Lucide is the production stand-in) and ask the user for proprietary marks.
- Don't surface affordances Veridia or CloudClinic don't actually have. Veridia is **mediated-only**. CloudClinic is **non-clinical**.
- Don't use rounded corner + left-border accent banners. Use the `.banner-*` classes.
