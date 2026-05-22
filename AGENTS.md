# Repository Guidelines

## Project Overview

Lumen is a macOS menu bar utility that reads the MacBook's ambient light sensor (ALS) via IOKit and automatically switches between Light/Dark appearance based on ambient lighting. **Cannot be distributed on the App Store**—sandbox blocks IOKit ALS access.

## Build Commands

```bash
# Build with Xcode
xcodebuild -project Lumen.xcodeproj -scheme Lumen -destination 'platform=macOS' build

# Build with SwiftPM (no tests)
swift build

# Run tests
xcodebuild -project Lumen.xcodeproj -scheme Lumen -destination 'platform=macOS' test
```

## Architecture

- **Entry point**: `Lumen/Sources/App/main.swift` → `AppDelegate` → `MainAppController`
- **Protocol-based DI**: Core components implement `ALSReadingProtocol`, `AppearanceSwitching`, `ClamshellDetecting`, `ThresholdEngineDelegate`
- **ALS Reading**: `ALSReader` uses runtime-loaded IOKit private APIs (see `PrivateAPILoader.swift`)
- **Appearance Switching**: `AppearanceSwitcher` uses AppleScript; gracefully degrades if System Events permission denied
- **Clamshell Detection**: `ClamshellDetector` handles lid-closed scenarios (pauses ALS monitoring)

## Key Source Directories

```
Lumen/Sources/
├── App/           # main.swift, AppDelegate, MainAppController, LaunchAtLoginManager
├── ALS/           # ALSReader, ALSReading (ambient light sensor I/O)
├── Appearance/    # AppearanceSwitcher, AppearanceState, AppleScriptRunner
├── Engine/        # ThresholdEngine, ThresholdConfig, SettingsStore, DebounceTimer
├── Clamshell/     # ClamshellDetector, ClamshellState
├── UI/            # MenuBarController, SettingsViewController, StatusBarIcon
├── Bridging/      # PrivateAPILoader, IOKitBridging, Lumen-Bridging-Header.h
└── Resources/     # Images (avatars, backdrops, icons), Assets.xcassets
```

## Testing

- Tests are in `LumenTests/` with subdirectories matching source structure
- Run single test class: `xcodebuild test -only-testing:LumenTests/ALSReaderTests`
- **Note**: ALS-related tests may require physical MacBook with ambient light sensor; simulator returns nil readings

## Critical Constraints

- **Platform**: macOS 14.0+ only (set in `Package.swift` and `Info.plist`)
- **LSUIElement**: App is a menu bar agent (no dock icon)
- **Entitlements**: Requires `disable-library-validation` and `allow-unsigned-executable-memory` for IOKit private API access
- **Distribution**: Must be signed with Developer ID and notarized for distribution outside App Store; use `scripts/notarize.sh` (configure `DEVELOPER_ID` first)

## Assets

Image assets are documented in `ASSETS.md`. Run `scripts/generate_assets.swift` to generate placeholder assets if needed.

## Commit Style

From git history: use conventional commits (`feat:`, `chore:`, `fix:`) with descriptive messages. Example: `feat(lumen): redesign settings UI, fix Light Side logic`
