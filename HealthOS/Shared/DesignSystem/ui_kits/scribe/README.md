# Scribe UI kit

Professional clinical workspace. Recreation of the macOS 26+ first-slice surface defined in `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/` of the source repo, evolved one step toward the documented `NavigationSplitView` target in `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`.

## Components

| File | Purpose |
|:---|:---|
| `MacWindow.jsx` | Window chrome (traffic lights, toolbar) |
| `Sidebar.jsx` | NavigationSplitView sidebar with sessions list |
| `SessionHeader.jsx` | Patient pill + session id + state capsule |
| `GlassCard.jsx` | Generic glass-effect grouped card |
| `OutputBlock.jsx` | Title + recess block (matches scaffold's OutputBlock) |
| `Capsule.jsx` | Semantic state pill |
| `GatePanel.jsx` | Approve/reject panel |
| `Banner.jsx` | Degraded / denied / failed / info |
| `Button.jsx` | Default / primary / gate-prominent / text |

## Recreated screens

The `index.html` is a click-thru that walks: open session → select patient → submit capture → review SOAP draft → resolve gate. State is fake; visuals match scaffold + design-system tokens.
