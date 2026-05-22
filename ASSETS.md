# Lumen Image Asset Generation Guide

This document specifies all image assets needed for the Lumen app. These can be generated using any image generation service (Codex, Midjourney, DALL-E, etc.).

---

## A. Personality Avatars (Human-Style, Fun)

Generate **12 avatar images** (6 personalities × 2 modes). Each should be a stylized human character portrait, 512×512px, circular crop, fun/cartoonish but polished style.

### Style Guide
- Consistent character art style across all — modern app icons/avatars, slightly stylized but not too cartoonish
- Expressive faces, clear personality
- Use the emoji as the emotional anchor
- Circular composition, centered subject

### Avatar Specifications

#### 1. Cave Dweller 🌑

**Dark Mode — `avatar_cave_dweller_dark.png`**
Pale goth teenager in a black hoodie, hunched over a laptop in a dark cave, screen glow illuminating their face, slightly vampire aesthetic, mysterious and moody.

**Light Mode — `avatar_cave_dweller_light.png`**
Same character but now outdoors at night under a starry sky, holding a glowing lantern, curious expression, exploring the darkness rather than hiding in it.

#### 2. Cozy Corner 🕯️

**Dark Mode — `avatar_cozy_corner_dark.png`**
Bookish person in oversized sweater, surrounded by candles, warm amber lighting, holding tea, content smile, hygge aesthetic.

**Light Mode — `avatar_cozy_corner_light.png`**
Same person at a sunny window seat, natural light streaming in, plants everywhere, still with tea but brighter, more energized expression.

#### 3. Office Warrior 💡

**Dark Mode — `avatar_office_warrior_dark.png`**
Stressed but determined worker in business casual, under harsh fluorescent lights, coffee in hand, monitor tan, grinding through the day.

**Light Mode — `avatar_office_warrior_light.png`**
Same worker but at a standing desk near a big window, natural light, actually smiling, plant on desk, thriving instead of surviving.

#### 4. Cloud Browsing ☁️

**Dark Mode — `avatar_cloud_browsing_dark.png`**
Daydreamer lying on grass looking up at dramatic overcast sky, headphones on, relaxed, muted tones, introspective mood.

**Light Mode — `avatar_cloud_browsing_light.png`**
Same pose but now there's a rainbow breaking through the clouds, brighter, more vibrant, hopeful expression, optimism emerging.

#### 5. Beach Mode ☀️

**Dark Mode — `avatar_beach_mode_dark.png`**
Surfer/sun-worshipper with sunglasses, golden hour beach, tan lines, wind in hair, very energetic, living their best life.

**Light Mode — `avatar_beach_mode_light.png`**
Same person at a beach bonfire at dusk, warm fire glow, cozy hoodie over swimsuit, chill vibes, winding down from the day.

#### 6. Solar Panel 🌞

**Dark Mode — `avatar_solar_panel_dark.png`**
Techie in reflective sunglasses and solar-panel-patterned shirt, desert setting, almost too bright, intense, futuristic energy.

**Light Mode — `avatar_solar_panel_light.png`**
Same person at a rooftop solar farm at sunset, dramatic silhouette, orange sky, visionary pose, contemplating renewable future.

---

## B. Backdrop Scenes (2 per Setting)

Generate **12 backdrop images** (6 settings × 2 scenes each). These are atmospheric backgrounds for the live sensor reading card. 1200×400px, blurred/atmospheric, suitable for text overlay.

### Style Guide
- Photorealistic but slightly idealized
- Soft focus in foreground for text readability
- Rich color grading that matches each level's hex colors
- Each scene should immediately evoke the lux level
- Horizontal composition, center-weighted

### Backdrop Specifications

#### 1. Cave Dweller (10 lux) — Deep, Mysterious

**Scene A — `backdrop_cave_dweller_a.png`**
Deep underground cave with bioluminescent fungi, crystal formations, mysterious blue-green glow, still water reflection, ethereal and otherworldly.

*Color palette: Deep blues, teals, blacks (#0a0a1a, #1a1a3e)*

**Scene B — `backdrop_cave_dweller_b.png`**
Home theater room with massive screen glow, red velvet seats, total darkness except for the cinematic light, immersive entertainment.

*Color palette: Deep blacks, screen glow blues (#1e1e3f, #2d2d5a)*

#### 2. Cozy Corner (100 lux) — Warm, Intimate

**Scene A — `backdrop_cozy_corner_a.png`**
Reading nook by a brick fireplace, warm fire, stack of books, cat sleeping nearby, amber light, ultimate comfort.

*Color palette: Warm browns, ambers, embers (#1a0f0a, #3d2317)*

**Scene B — `backdrop_cozy_corner_b.png`**
Rainy cafe window with rain streaks on glass, warm interior lights, blurred city outside, coffee steam rising, cozy refuge.

*Color palette: Warm browns, soft lights (#4a2c1a, #6b3e26)*

#### 3. Office Warrior (400 lux) — Productive, Bright

**Scene A — `backdrop_office_warrior_a.png`**
Open plan office with desks, monitors, white ceiling, fluorescent strips, busy but organized, slightly sterile but functional.

*Color palette: Cool blues, whites (#0f1f2e, #1a3a4f)*

**Scene B — `backdrop_office_warrior_b.png`**
Library study hall with long wooden tables, green banker's lamps, high ceilings, focused quiet energy, academic excellence.

*Color palette: Rich blues, warm wood tones (#2a5298, #1e3c72)*

#### 4. Cloud Browsing (6,400 lux) — Soft, Diffuse

**Scene A — `backdrop_cloud_browsing_a.png`**
Seattle skyline on overcast day, gray clouds, Space Needle silhouette, moody and atmospheric, Pacific Northwest vibes.

*Color palette: Soft grays, muted blues (#1a2530, #2a3a4a)*

**Scene B — `backdrop_cloud_browsing_b.png`**
English countryside with rolling green hills, sheep grazing, heavy cloud cover, soft diffuse light, peaceful and pastoral.

*Color palette: Soft blues, gentle greens (#89a8c4, #b8d4e3)*

#### 5. Beach Mode (12,800 lux) — Bright, Vibrant

**Scene A — `backdrop_beach_mode_a.png`**
Tropical beach at noon, white sand, turquoise water, palm trees, harsh bright sun, vacation energy, paradise found.

*Color palette: Bright turquoise, deep blues (#00b4db, #0083b0)*

**Scene B — `backdrop_beach_mode_b.png`**
Mediterranean cliffside, bright blue sea, white buildings, sun-bleached rocks, dazzling light, European summer.

*Color palette: Azure blues, warm whites (#00b4db, #0083b0)*

#### 6. Solar Panel (25,600 lux) — Intense, Extreme

**Scene A — `backdrop_solar_panel_a.png`**
Death Valley at midday, salt flats, heat shimmer, blinding white light, solar farm in distance, extreme conditions.

*Color palette: Hot oranges, deep reds (#3a1f15, #5a3020)*

**Scene B — `backdrop_solar_panel_b.png`**
Space station solar array orbiting Earth, gold/blue solar panels, harsh unfiltered sunlight, sci-fi grandeur, future energy.

*Color palette: Hot coral, deep orange (#ff9966, #ff5e62)*

---

## C. Side Selector Icons

### Dark Side Avatar — `icon_dark_side.png`
256×256px circular icon. Deep purple-blue gradient background (#1a1a3e to #2d2b55). White crescent moon and stars symbol in center. Mysterious, cool, night-themed. Like a premium app icon.

### Light Side Avatar — `icon_light_side.png`
256×256px circular icon. Warm orange-coral gradient background (#f4a261 to #e76f51). White sun symbol with radiating lines in center. Energetic, warm, day-themed. Like a premium app icon.

---

## File Organization

```
Lumen/
└── Resources/
    └── Images/
        ├── avatars/
        │   ├── avatar_cave_dweller_dark.png
        │   ├── avatar_cave_dweller_light.png
        │   ├── avatar_cozy_corner_dark.png
        │   ├── avatar_cozy_corner_light.png
        │   ├── avatar_office_warrior_dark.png
        │   ├── avatar_office_warrior_light.png
        │   ├── avatar_cloud_browsing_dark.png
        │   ├── avatar_cloud_browsing_light.png
        │   ├── avatar_beach_mode_dark.png
        │   ├── avatar_beach_mode_light.png
        │   ├── avatar_solar_panel_dark.png
        │   └── avatar_solar_panel_light.png
        ├── backdrops/
        │   ├── backdrop_cave_dweller_a.png
        │   ├── backdrop_cave_dweller_b.png
        │   ├── backdrop_cozy_corner_a.png
        │   ├── backdrop_cozy_corner_b.png
        │   ├── backdrop_office_warrior_a.png
        │   ├── backdrop_office_warrior_b.png
        │   ├── backdrop_cloud_browsing_a.png
        │   ├── backdrop_cloud_browsing_b.png
        │   ├── backdrop_beach_mode_a.png
        │   ├── backdrop_beach_mode_b.png
        │   ├── backdrop_solar_panel_a.png
        │   └── backdrop_solar_panel_b.png
        └── icons/
            ├── icon_dark_side.png
            └── icon_light_side.png
```

---

## Implementation Notes

### Avatars
- Display at 64×64px in the level selector rows
- Use circular mask with 2px border matching the level's accent color
- Show dark mode avatar when macOS is in dark mode, light mode avatar when in light mode
- Add subtle shadow for depth

### Backdrops
- Display as 1200×400px background behind the live sensor reading
- Apply 40% dark overlay to ensure white text readability
- Use `background-size: cover` with slight parallax on mouse move
- Crossfade between scenes every 30 seconds or on threshold change
- Show Scene A by default, Scene B as alternate

### Icons
- Display at 120×120px for the side selector buttons
- Circular with subtle inner shadow
- Selected state adds 3px accent-colored ring
- Unselected state dims to 50% opacity

---

## Color Reference

| Level | Dark Mode Top | Dark Mode Bottom | Light Mode Top | Light Mode Bottom |
|---|---|---|---|---|
| Cave Dweller | #0a0a1a | #1a1a3e | #1e1e3f | #2d2d5a |
| Cozy Corner | #1a0f0a | #3d2317 | #4a2c1a | #6b3e26 |
| Office Warrior | #0f1f2e | #1a3a4f | #2a5298 | #1e3c72 |
| Cloud Browsing | #1a2530 | #2a3a4a | #89a8c4 | #b8d4e3 |
| Beach Mode | #1a3028 | #2a5040 | #00b4db | #0083b0 |
| Solar Panel | #3a1f15 | #5a3020 | #ff9966 | #ff5e62 |

---

## D. Code Integration Guide

Once images are generated, follow these steps to wire them into the app.

### Step 1: Add Images to Xcode Project

1. Create folder references in Xcode:
   - Right-click `Lumen/` → **Add Files to "Lumen"**
   - Select `Resources/Images/avatars/`, `Resources/Images/backdrops/`, `Resources/Images/icons/`
   - Check **"Create folder references"** (not groups)
   - Ensure **"Add to targets: Lumen"** is checked

2. Verify images appear in **Build Phases → Copy Bundle Resources**.

### Step 2: Update `LuxLevel` to Reference Avatars

In `Lumen/Sources/Engine/ThresholdConfig.swift`, add image names:

```swift
public func avatarImageName(isDark: Bool) -> String {
    let suffix = isDark ? "dark" : "light"
    switch self {
    case .darkRoom:     return "avatar_cave_dweller_\(suffix)"
    case .dimIndoor:    return "avatar_cozy_corner_\(suffix)"
    case .brightIndoor: return "avatar_office_warrior_\(suffix)"
    case .overcast:     return "avatar_cloud_browsing_\(suffix)"
    case .sunny:        return "avatar_beach_mode_\(suffix)"
    case .directSun:    return "avatar_solar_panel_\(suffix)"
    }
}

public func backdropImageNames() -> [String] {
    switch self {
    case .darkRoom:     return ["backdrop_cave_dweller_a", "backdrop_cave_dweller_b"]
    case .dimIndoor:    return ["backdrop_cozy_corner_a", "backdrop_cozy_corner_b"]
    case .brightIndoor: return ["backdrop_office_warrior_a", "backdrop_office_warrior_b"]
    case .overcast:     return ["backdrop_cloud_browsing_a", "backdrop_cloud_browsing_b"]
    case .sunny:        return ["backdrop_beach_mode_a", "backdrop_beach_mode_b"]
    case .directSun:    return ["backdrop_solar_panel_a", "backdrop_solar_panel_b"]
    }
}
```

### Step 3: Update `SettingsViewController` — Level Selector Avatars

In `makeLevelRow(for:)`, replace the plain label with an avatar image:

```swift
private func makeLevelRow(for level: LuxLevel) -> NSView {
    let row = NSStackView()
    row.orientation = .horizontal
    row.spacing = 12
    row.alignment = .centerY

    let btn = NSButton(radioButtonWithTitle: "", target: self, action: #selector(levelButtonClicked(_:)))
    btn.tag = Int(level.rawValue)
    levelButtons.append(btn)

    // Avatar image view
    let avatar = NSImageView()
    avatar.image = NSImage(named: level.avatarImageName(isDark: isDarkMode()))
    avatar.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        avatar.widthAnchor.constraint(equalToConstant: 40),
        avatar.heightAnchor.constraint(equalToConstant: 40)
    ])
    // Circular mask
    avatar.wantsLayer = true
    avatar.layer?.cornerRadius = 20
    avatar.layer?.masksToBounds = true

    let label = NSTextField(labelWithString: "")
    label.tag = Int(level.rawValue) + 1000

    row.addArrangedSubview(btn)
    row.addArrangedSubview(avatar)
    row.addArrangedSubview(label)
    return row
}

private func isDarkMode() -> Bool {
    view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
}
```

Also update `updateLevelSelection()` to refresh avatar images when the level changes:

```swift
private func updateLevelSelection() {
    let threshold = settings.lightThreshold
    let isDark = isDarkMode()
    
    for btn in levelButtons {
        if btn.tag == 999 {
            // ... existing custom logic ...
        } else if let level = LuxLevel(rawValue: Double(btn.tag)) {
            let isMatch = abs(level.rawValue - threshold) < 0.1
            btn.state = isMatch ? .on : .off
            
            // Update label
            if let label = btn.superview?.viewWithTag(Int(level.rawValue) + 1000) as? NSTextField {
                label.attributedStringValue = levelButtonTitle(for: level, selected: isMatch)
            }
            
            // Update avatar image
            if let avatar = btn.superview?.subviews.compactMap({ $0 as? NSImageView }).first {
                avatar.image = NSImage(named: level.avatarImageName(isDark: isDark))
            }
        }
    }
    updateBackdrop()
}
```

### Step 4: Update `SettingsViewController` — Backdrop Images

Replace the gradient backdrop with an image view. In `makeLiveReading()`:

```swift
private var backdropImageView: NSImageView!

private func makeLiveReading() -> NSView {
    let container = NSView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.heightAnchor.constraint(equalToConstant: 100).isActive = true

    backdropImageView = NSImageView()
    backdropImageView.imageScaling = .scaleAxesIndependently
    backdropImageView.wantsLayer = true
    backdropImageView.layer?.cornerRadius = 12
    backdropImageView.layer?.masksToBounds = true
    backdropImageView.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(backdropImageView)

    // Dark overlay for text readability
    let overlay = NSView()
    overlay.wantsLayer = true
    overlay.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
    overlay.layer?.cornerRadius = 12
    overlay.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(overlay)

    NSLayoutConstraint.activate([
        backdropImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        backdropImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        backdropImageView.topAnchor.constraint(equalTo: container.topAnchor),
        backdropImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        
        overlay.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        overlay.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        overlay.topAnchor.constraint(equalTo: container.topAnchor),
        overlay.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ])

    // ... add sensorLabel, luxValueLabel, etc. as subviews of container (not backdrop) ...
    
    updateBackdrop()
    return container
}
```

Update `updateBackdrop()` to load images:

```swift
private func updateBackdrop() {
    let level = LuxLevel.allCases.min(by: {
        abs($0.rawValue - settings.lightThreshold) < abs($1.rawValue - settings.lightThreshold)
    }) ?? .brightIndoor
    
    let imageNames = level.backdropImageNames()
    // Pick scene A by default, or alternate based on time/side
    let imageName = imageNames.first ?? ""
    backdropImageView?.image = NSImage(named: imageName)
}
```

### Step 5: Update `SettingsViewController` — Side Selector Icons

In `makeSideSelector()`, replace the gradient avatar buttons with image-based ones:

```swift
private func makeSideSelector() -> NSView {
    let stack = NSStackView()
    stack.orientation = .vertical
    stack.spacing = 8

    let label = NSTextField(labelWithString: "Choose Your Side")
    label.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
    label.textColor = .secondaryLabelColor
    stack.addArrangedSubview(label)

    let buttonStack = NSStackView()
    buttonStack.orientation = .horizontal
    buttonStack.spacing = 16
    buttonStack.alignment = .centerY
    buttonStack.distribution = .fillEqually

    // Dark Side button
    darkSideButton = makeIconSideButton(
        title: "Dark Side",
        imageName: "icon_dark_side",
        tag: 0,
        action: #selector(sideChanged(_:))
    )

    // Light Side button
    lightSideButton = makeIconSideButton(
        title: "Light Side",
        imageName: "icon_light_side",
        tag: 1,
        action: #selector(sideChanged(_:))
    )

    buttonStack.addArrangedSubview(darkSideButton)
    buttonStack.addArrangedSubview(lightSideButton)
    stack.addArrangedSubview(buttonStack)

    let desc = NSTextField(labelWithString: settings.side.subtitle)
    desc.font = NSFont.systemFont(ofSize: 11, weight: .regular)
    desc.textColor = .tertiaryLabelColor
    desc.tag = 100
    desc.alignment = .center
    stack.addArrangedSubview(desc)

    updateSideSelection()
    return stack
}

private func makeIconSideButton(title: String, imageName: String, tag: Int, action: Selector) -> NSButton {
    let button = NSButton()
    button.title = ""
    button.tag = tag
    button.target = self
    button.action = action
    button.bezelStyle = .regularSquare
    button.isBordered = false
    button.wantsLayer = true
    button.layer?.cornerRadius = 12
    button.layer?.masksToBounds = true

    let container = NSStackView()
    container.orientation = .vertical
    container.spacing = 6
    container.alignment = .centerX
    container.translatesAutoresizingMaskIntoConstraints = false

    let icon = NSImageView()
    icon.image = NSImage(named: imageName)
    icon.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        icon.widthAnchor.constraint(equalToConstant: 64),
        icon.heightAnchor.constraint(equalToConstant: 64)
    ])
    // Circular mask
    icon.wantsLayer = true
    icon.layer?.cornerRadius = 32
    icon.layer?.masksToBounds = true

    let label = NSTextField(labelWithString: title)
    label.font = NSFont.systemFont(ofSize: 11, weight: .medium)
    label.textColor = .labelColor
    label.alignment = .center

    container.addArrangedSubview(icon)
    container.addArrangedSubview(label)

    button.addSubview(container)
    NSLayoutConstraint.activate([
        container.centerXAnchor.constraint(equalTo: button.centerXAnchor),
        container.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        button.widthAnchor.constraint(equalToConstant: 120),
        button.heightAnchor.constraint(equalToConstant: 100)
    ])

    return button
}
```

Update `updateSideSelection()` to highlight the selected icon:

```swift
private func updateSideSelection() {
    guard let darkLayer = darkSideButton.layer, let lightLayer = lightSideButton.layer else { return }

    let isDark = settings.side == .darkSide

    // Selection ring
    darkLayer.borderWidth = isDark ? 3 : 0
    darkLayer.borderColor = NSColor.controlAccentColor.cgColor
    darkSideButton.alphaValue = isDark ? 1.0 : 0.5

    lightLayer.borderWidth = isDark ? 0 : 3
    lightLayer.borderColor = NSColor.controlAccentColor.cgColor
    lightSideButton.alphaValue = isDark ? 0.5 : 1.0

    updateSideDescription()
    levelHeaderLabel?.stringValue = thresholdLabelText()
}
```

### Step 6: Handle Dark Mode Changes

Override `viewDidChangeEffectiveAppearance` to refresh images when macOS switches between dark/light mode:

```swift
override func viewDidChangeEffectiveAppearance() {
    super.viewDidChangeEffectiveAppearance()
    updateLevelSelection()
    updateBackdrop()
}
```

### Step 7: Clean Up Removed Code

Delete the old gradient-related code:
- Remove `backdropGradient: CAGradientLayer!` property
- Remove `backdropView` (or repurpose it for the overlay)
- Remove `makeAvatarButton(title:symbol:bgColors:iconColor:tag:action:)` method
- Remove `updateBackdrop()` gradient logic
- Remove `NSColor(hex:)` extension if no longer used

### Step 8: Build & Test

1. Build (`Cmd+B`) — ensure no compile errors
2. Verify images load in dark and light macOS appearances
3. Check that avatars change when selecting different lux levels
4. Confirm backdrops update when threshold changes
5. Test side selector icon highlighting

---

*Generated for Lumen — Auto Light Mode*
