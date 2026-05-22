# Help Tooltips Implementation Plan

## Context

The app's settings UI in `SettingsViewController.swift` currently shows controls (slider, radio buttons, labels) with no explanations. Users need small, unobtrusive popups to understand what each setting does.

**Chosen approach**: Use macOS native `NSToolTip` — the standard AppKit tooltip system. This requires zero dependencies and is automatically handled by the system (appear on hover after 500ms delay).

**Key decisions**:
- Tooltips only on interactive or non-obvious elements
- Text is concise (1-2 sentences max)
- No structural changes to the UI layout

## Changes

1. **`Lumen/Sources/UI/SettingsViewController.swift`** — Add tooltips to key controls

   - `quickSetButton`: `"Set the threshold to 90% of the current ambient light reading."`
   - `thresholdSlider` (wrapping stack): `"When ambient light exceeds this value, Lumen switches to Light appearance."`
   - Debounce radio buttons (wrapping stack): `"Wait time before switching appearance. Prevents rapid toggling from brief light changes."`
   - `autoButton`: `"Resume automatic light/dark switching after pausing."`

2. **`Lumen/Sources/UI/SettingsViewController.swift`** — Add tooltip to non-obvious static labels

   - `luxValueLabel` (the large lux number): `"Current ambient light in lux (lx). Higher values mean brighter environments."`
   - `luxLevelIndicator`: `"Color indicates current light level — dark blue for dim, orange for bright."`

3. **`Lumen/Sources/UI/SettingsViewController.swift`** — Add tooltip to Ko-fi link

   - Ko-fi button: `"Support Lumen development on Ko-fi."`

## Verification

Build the project to confirm no compilation errors:
```bash
xcodebuild -project Lumen.xcodeproj -scheme Lumen -destination 'platform=macOS' build
```

## Conventions and Reference

- Existing `SettingsViewController.swift` structure: lines 60–91 (`setupUI` composes sections via `makeThresholdSection()`, `makeDebounceSection()`, etc.)
- Tooltip assignment pattern: `view.toolTip = "text"` — standard AppKit API
- All tooltips use short, helpful sentences explaining the setting's purpose