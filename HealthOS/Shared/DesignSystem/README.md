# HealthOS Design System

> **Sovereign computational environment for health data and clinical operations.**
> A macOS 26+ native design system built on Apple's **Liquid Glass** baseline.

HealthOS is a governance-first clinical platform. Every clinical act flows through a strictly layered, consent- and provenance-governed fabric. The design system describes the **interface skin** over that fabric — it is presentation, never law.

This design system is for the **scaffold/foundation phase**. It targets macOS 26+ (Apple Silicon), uses **SF Pro** + system materials, and adopts **Liquid Glass** for HealthOS-specific custom surfaces. No Core law, consent, habilitation, gate, finality, GOS, session orchestration, or MSR runtime behavior is encoded here. Apps consume mediated state.

---

## Sources

This design system was distilled from the public scaffold repository:

- **Repo:** `myselfgus/HealthOScaffold` (branch `main`)
- **Canonical UI doctrine:** `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`
- **Interface boundaries:** `HealthOS/Shared/docs/architecture/19-interface-doctrine.md`, `11-scribe.md`, `12-veridia.md`, `13-cloudclinic.md`
- **Screen contracts:** `HealthOS/Shared/docs/architecture/23-scribe-screen-contracts.md`, `24-veridia-screen-contracts.md`, `25-cloudclinic-screen-contracts.md`
- **Existing Swift surface:** `HealthOS/Tier4-Stages-Cast/Scribe/Sources/HealthOSScribeStage/` (the only interactive shell — a minimal SwiftUI validation app using `GroupBox` + `.thinMaterial`)

The scaffold repo contains **no logo, brand assets, or color tokens** — only doctrine, screen contracts, and a SwiftPM SwiftUI surface. This system fills that gap with a **proposed identity** rooted in the platform's stated values: sovereignty, governance, contract law, and Apple-native execution. Treat the wordmark, accent, and motif choices as **scaffold proposals** ready for the user's review.

---

## Index

```
README.md                    ← this file
SKILL.md                     ← agent skill manifest (Claude Code compatible)
colors_and_type.css          ← CSS vars: colors, type, spacing, radii, shadows, glass
fonts/                       ← font files + Google-Fonts substitution notes
assets/                      ← logos, motif marks, app glyphs
preview/                     ← design-system tab cards (one HTML per swatch/specimen)
ui_kits/
  scribe/                    ← professional clinical workspace
    index.html               ← interactive recreation of the first-slice surface
    *.jsx                    ← components (sidebar, glass cards, gate panel, etc)
    README.md
  veridia/                   ← patient health identity surface (mediated) (scaffolded contract — placeholder kit)
    index.html
    README.md
  cloudclinic/               ← service operations (contract-only — placeholder kit)
    index.html
    README.md
```

No slide template was attached, so no `slides/` folder is generated.

---

## Brand / product context

HealthOS is the platform. **Three apps** consume mediated surfaces:

| App | Audience | Posture |
|:---|:---|:---|
| **Scribe** | Clinicians (professional) | Implemented validation surface (first-slice). |
| **Veridia** | Patients (health identity / mediated) | Scaffolded contract. No native shell yet. |
| **CloudClinic** | Service operators (queues, ops) | Contract-only. No native shell yet. |

The platform name reads **HealthOS** (one word, capital H + capital OS). Repository naming uses `HealthOScaffold` for the scaffold phase. Architecture is documented in **Portuguese (Brazil)** in app-facing copy and **English** in code/docs — both are first-class.

---

## Content fundamentals

### Voice
- **Sober, precise, governance-aware.** Copy reads like contract documentation, not marketing. The product calls itself a "sovereign computational environment," not "the future of health."
- **Honest about maturity.** Surfaces label themselves "scaffold," "validation surface," "stub," "degraded," "preview only." Never claims production readiness, EHR completeness, or signature/regulatory authority that doesn't exist.
- **Outcomes are states, not feelings.** Result UI surfaces `complete_success`, `partial_success`, `governed_deny`, `degraded`, `operational_failure` — never "Oops!" or "Great!".

### Casing & form
- **Sentence case** for headings, buttons, labels, menu items. (`Open professional session`, not `Open Professional Session`.)
- **Title Case is rare** — reserved for proper-noun product names: `HealthOS`, `Scribe`, `Veridia`, `CloudClinic`, `Liquid Glass`, `Apple Silicon`.
- **Snake-cased identifiers in technical state surfaces** stay literal: `seeded_text`, `awaiting_gate`, `governed_deny`. UI may show them verbatim in audit/debug contexts.
- **Bilingual:** the existing scaffold uses Brazilian Portuguese in user-visible copy ("Superficie minima de validacao funcional", "Abra a sessao para habilitar selecao de paciente") with English technical labels mixed in. Designs MAY use either, but should pick one per surface and stay consistent.

### Person / address
- **Third-person + imperative**, not "you" or "I". `Open session`, `Select patient`, `Submit capture` — instructional, not conversational.
- Patient-facing Veridia is the only surface where a softer "Your data" / "Seus dados" register is acceptable.

### Examples (lifted verbatim from the scaffold)
- `Scribe First Slice Surface` (window title)
- `Superficie minima de validacao funcional. A UI consome a bridge do first slice e apenas mostra estado, gate e degradacao.` (description block)
- `Abra a sessao para habilitar selecao de paciente e captura por texto seeded ou audio local.` (empty-state hint)
- `Nenhum issue ativo no momento.` (empty issues card)
- `governance deny`, `lawful-context`, `mediated surface` (architecture vocabulary)

### Emoji
- **Not in product UI.** The scaffold's app surfaces use zero emoji.
- **Allowed in repo docs / READMEs** as section markers (🏗️ 📦 🪟 🚀 🤖 🗺️) where they aid scannability — but never in shipping interface.

### Vibe
**Operating room meets compiler output.** Calm, technical, complete. Information dense but not crowded. Every visible piece of state has a name and a defined set of values. Nothing is hidden behind decorative chrome.

---

## Visual foundations

### Type
- **Display + UI:** `SF Pro Display` / `SF Pro Text` (system default on macOS). Full system stack with `-apple-system`, `BlinkMacSystemFont` fallbacks.
- **Rounded:** `SF Pro Rounded` is reserved for **Veridia** (patient-facing, friendlier register) and for app-name wordmarks. The repo's mermaid diagrams use `ui-rounded` — that's a deliberate choice for "narrative" surfaces.
- **Mono:** `SF Mono` for transcripts, identifiers (`UUID`s, tokens), JSON previews, audit lines. The scaffold uses `.font(.body.monospaced())` for the capture text editor.
- **Substitution flag:** SF Pro and SF Mono ship with macOS but cannot be redistributed. For web/HTML mocks we substitute **Inter** (closest neutral grotesque) and **JetBrains Mono** (closest mono with similar metrics) via Google Fonts. **For production native UI, always use SF Pro / SF Mono.**

### Color
HealthOS extends the **system-adaptive macOS palette** rather than replacing it. Three layers:

1. **System foundation** — `labelColor`, `secondaryLabelColor`, `controlBackgroundColor`, `windowBackgroundColor`. These adapt to light/dark automatically. Use them for everything not branded.
2. **HealthOS accents** — a custom palette of clinical-feeling, low-saturation hues used **semantically**:
   - `--hos-sovereign` (deep indigo `#3B4A6B`) — primary brand accent, used sparingly
   - `--hos-mediated` (cyan-teal `#0E7C86`) — "data flowing through governance" — links, focus rings, mediation markers
   - `--hos-glass-tint` (cool slate `#5B6B7C`) — Liquid Glass tint for HealthOS-specific surfaces
3. **Semantic state** — drives every state badge, banner, and pill:
   - `--state-ready` green / `--state-degraded` amber / `--state-denied` rose / `--state-pending` slate / `--state-final` deep teal / `--state-withheld` muted plum

All accents are tuned to read against `.thinMaterial` and Liquid Glass without fighting the system tint. Tint is **always semantic**, never decorative — per `HealthOS/Shared/docs/architecture/48`.

### Spacing
8-pt grid. Token scale: `--space-1` 4px · `--space-2` 8px · `--space-3` 12px · `--space-4` 16px · `--space-5` 20px · `--space-6` 24px · `--space-8` 32px · `--space-10` 40px · `--space-12` 48px · `--space-16` 64px. The scaffold uses `padding(20)` and `spacing: 16`/`14`/`12`/`8` — these are the canonical rhythm.

### Backgrounds
- **No full-bleed photography.** No hand-drawn illustrations. No decorative gradients.
- **System materials over semi-opaque windows.** Sidebar uses `regularMaterial`. Detail uses default `windowBackgroundColor`. Cards use `thinMaterial` (current scaffold) → `glassEffect` (macOS 26+ target).
- **Subtle radial wash** is acceptable on app launch / empty states only — a single low-opacity radial gradient from `--hos-sovereign` at 4–8% to transparent. Anything more is decorative.
- **Patterns / textures:** none.

### Animation
- **System-native easing.** Use SwiftUI's default spring curves. For web mocks, `cubic-bezier(0.25, 0.1, 0.25, 1)` (ease-out) for entrances, `cubic-bezier(0.4, 0, 0.6, 1)` for state changes. **Duration: 180–240ms.** Glass surface re-flow (when a `GlassEffectContainer` reshapes): **300–360ms**, slightly slower to feel substantial.
- **No bounces, no overshoots, no parallax.** Liquid Glass already carries motion through its specular reflections — additional motion competes.
- **Fades are the default state-change.** Slides in from below (8–12px) for sheet-like enters. Gate approve/reject flips: a single 200ms cross-fade between draft and final states.

### Hover / press states
- **Hover (mouse):** background lifts 4–6% in luminance. On glass, increases internal tint by 6%. **Never** changes color hue on hover.
- **Press:** scale `0.98`, brightness `0.96`, 80ms ease-out → release in 120ms ease-in. On gate-prominent buttons, add a one-frame inner ring of the semantic accent at 40% opacity.
- **Focus ring:** `--hos-mediated` at 70% opacity, `2px` outer + `1px` offset. Always visible for keyboard nav. Mac default focus ring is acceptable for system controls.

### Borders
- **Hairline only.** `0.5px` (retina) / `1px` (1x) at `color-mix(in srgb, var(--label) 12%, transparent)`. Cards prefer **no border + subtle shadow** over a visible border.
- Glass surfaces: borders are integral to the material — don't add CSS borders on top.

### Shadows / elevation
Three levels:
- **`--shadow-recess`** (inset): for input fields and pressed states.
  `inset 0 1px 0 0 rgba(0,0,0,0.04), inset 0 0 0 0.5px rgba(0,0,0,0.06)`
- **`--shadow-card`** (resting card): `0 1px 0 0 rgba(0,0,0,0.04), 0 1px 3px 0 rgba(0,0,0,0.06)`
- **`--shadow-floating`** (popover, sheet, modal): `0 8px 24px -4px rgba(0,0,0,0.16), 0 2px 6px 0 rgba(0,0,0,0.08)`

No glow, no colored shadows, no neumorphism.

### Capsules vs gradients
- **Capsules win.** Status pills, role tags, gate decisions all use **fully-rounded capsules** (`border-radius: 9999px`), filled with the semantic color at **8% opacity**, text at full semantic color. Solid-fill capsules only for gate-prominent CTAs.
- **No protection gradients.** If text needs to read over an image, use a single solid material layer instead.

### Layout rules
- **`NavigationSplitView` is the default.** Sidebar (collapsible) → detail → optional inspector. The scaffold's single `ScrollView` is a validation shortcut, not the target.
- **Fixed:** the sidebar sits at the leading edge. The toolbar sits at the top. Both inherit system Liquid Glass — never rebuild them.
- **Min window:** `860 × 760` (taken directly from `ScribeFirstSliceView.frame(minWidth: 860, minHeight: 760)`).
- **Content max width inside detail:** `~720px` for prose-like state surfaces; full-width for queues/tables.
- **Card grouping:** one logical group = one `GlassEffectContainer`. Don't nest containers.

### Transparency & blur
- **Materials, not opacity.** Use `regularMaterial`, `thinMaterial`, `ultraThinMaterial` — the system handles blur. CSS mocks: `backdrop-filter: blur(20px) saturate(1.6)` on `rgba(255,255,255,0.6)` (light) / `rgba(28,28,30,0.6)` (dark).
- **When to use glass vs solid:** glass for *grouped HealthOS-specific custom surfaces* (session card, gate panel). **Solid `windowBackgroundColor`** for primary content text (transcripts, audit lines) — readability over effect.
- **Blur fallbacks:** if `backdrop-filter` is unsupported, fall back to `windowBackgroundColor` at 95% — never a transparent untreated panel.

### Imagery
There is none. No clinical photography, no illustrations, no avatars beyond initials. Identifiers in the scaffold are **tokens** (`civilToken`, `UUID`) — visualize them as monospaced text in pill or rectangular badges, not as faces.

If imagery is ever introduced (e.g. patient health identity illustrations in Veridia): cool-tone, low-saturation, line-art only. Never warm, never grainy, never b&w photography.

### Corner radii
- **`--radius-sm` 6px** — pills, small badges, inline tags
- **`--radius-md` 8px** — buttons, input fields, OutputBlocks (the scaffold uses exactly 8px)
- **`--radius-lg` 12px** — cards, glass containers
- **`--radius-xl` 16px** — sheets, modals, the app window itself (macOS standard)
- **`--radius-pill` 9999px** — status capsules

### Cards
A HealthOS card is:
- `--radius-lg` (12px) corners
- `thinMaterial` background (current) → `glassEffect` (macOS 26+)
- `--shadow-card` resting elevation
- **No border** (the material's edge does that work)
- `--space-5` (20px) interior padding
- Title in `headline` size + weight 600 at the top, then a `--space-3` (12px) gap, then content

The scaffold's `OutputBlock` is the prototype: title in headline, text in body, `thinMaterial` background, `8px` radius, `10px` interior padding. Cards are `OutputBlock` scaled up.

---

## Iconography

The scaffold contains **no custom icon set, no icon font, no SVG kit, no PNG asset directory** (`HealthOS/Shared/docs/assets/` is referenced for GIFs in the README but the directory itself is not present in the importable tree). All icon needs in the existing Scribe surface are met by **Apple's SF Symbols** — the system icon font for macOS/iOS, available natively in SwiftUI as `Image(systemName:)`.

### Approach
- **SF Symbols is the canonical icon set.** Stroke style: `regular` weight, `medium` scale by default. Use `bold` only for prominent toolbar actions, `semibold` for selected states.
- **Multicolor / hierarchical / palette modes** are allowed but should follow semantic colors (e.g. `xmark.shield` rendered with `--state-denied` palette).
- **Substitution for HTML mocks:** since SF Symbols cannot be embedded in web (it's an OS-only font), HTML kits use **Lucide** via CDN — a clean line-icon library with comparable stroke weight and corner treatment. **Flag:** Lucide is a substitute, not a brand asset; production native UI uses SF Symbols.
- **No emoji as iconography.** No unicode symbols (✓ ✗ ★) as standalone icons in the chrome — only inside content surfaces (e.g. transcript lines) where the user typed them.

### Conventions
- **App-bar icons:** SF Symbol at 17pt, regular weight, `secondaryLabelColor` until hovered.
- **Status icons** (in capsules / banners): SF Symbol at 13pt, semibold, semantic accent. Pair with a text label — never icon-only for states.
- **Gate-prominent actions** (approve / reject): icon + text, glass-prominent button style, semantic tint.
- **Veridia (patient-facing)** uses `SF Pro Rounded` typography and may use slightly **larger / softer SF Symbols** (`Image(systemName:).symbolRenderingMode(.hierarchical)`) for warmth.

### Substitution flag
- Lucide → SF Symbols (production)
- Inter → SF Pro Display / Text (production)
- JetBrains Mono → SF Mono (production)

The user should provide updated SF Pro / SF Mono / SF Symbols access for production native builds.

---

## How to use this system

1. **Mocks & prototypes** — open any file in `preview/` to see the swatches and specimens; open `ui_kits/scribe/index.html` for the interactive Scribe shell.
2. **New designs** — start from `colors_and_type.css` for tokens. Compose using `ui_kits/scribe/*.jsx` components.
3. **Production native code** — read `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` from the source repo as the authoritative spec. Use SwiftUI standard controls before custom glass.

For agent use, see `SKILL.md`.
