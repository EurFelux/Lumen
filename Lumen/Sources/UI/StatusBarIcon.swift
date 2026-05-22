import AppKit

enum StatusBarIcon {

    static func image(for mode: AppearanceMode) -> NSImage {
        if let image = loadLumenIcon() {
            image.size = NSSize(width: 18, height: 18)
            image.isTemplate = true
            return image
        }
        if let sfImage = NSImage(systemSymbolName: mode.symbolName, accessibilityDescription: mode.displayName) {
            sfImage.size = NSSize(width: 18, height: 18)
            sfImage.isTemplate = true
            return sfImage
        }
        return textFallbackImage(for: mode)
    }

    private static func loadLumenIcon() -> NSImage? {
        if let image = NSImage(named: "lumen_icon") {
            return image
        }

        let bundles = [Bundle.main] + Bundle.allBundles
        for bundle in bundles {
            if let url = bundle.url(forResource: "lumen_icon", withExtension: "png"),
               let image = NSImage(contentsOf: url) {
                return image
            }
        }

        let resourceBundleURL = Bundle.main.bundleURL
            .deletingLastPathComponent()
            .appendingPathComponent("Lumen_Lumen.bundle")
        if let bundle = Bundle(url: resourceBundleURL),
           let url = bundle.url(forResource: "lumen_icon", withExtension: "png") {
            return NSImage(contentsOf: url)
        }

        return nil
    }

    private static func textFallbackImage(for mode: AppearanceMode) -> NSImage {
        let text = mode == .light ? "☀︎" : "☾"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16),
            .foregroundColor: NSColor.labelColor,
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let size = NSSize(width: 18, height: 18)
        let textImage = NSImage(size: size, flipped: false) { rect in
            attributedString.draw(at: NSPoint(x: 1, y: 1))
            return true
        }
        textImage.isTemplate = true
        return textImage
    }
}
