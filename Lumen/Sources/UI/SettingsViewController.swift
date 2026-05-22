import AppKit
import Combine

protocol SettingsViewControllerActionDelegate: AnyObject {
    func settingsViewControllerDidToggleAutoSwitch(_ isEnabled: Bool)
    func settingsViewControllerDidRequestQuit()
}

final class SettingsViewController: NSViewController {

    private let settings: SettingsStore
    private var cancellables = Set<AnyCancellable>()

    weak var actionDelegate: SettingsViewControllerActionDelegate?

    private var luxValueLabel: NSTextField!
    private var luxLevelIndicator: NSView!
    private var thresholdValueLabel: NSTextField!
    private var thresholdSlider: NSSlider!
    private var debounceButtons: [NSButton] = []
    private var quickSetButton: NSButton!
    private var autoButton: NSButton!
    private var launchAtLoginCheckbox: NSButton!

    private var currentReading: ALSReading?

    private let minLux = 10.0
    private let maxLux = 100000.0
    private let minLog = log10(10.0)
    private let maxLog = log10(100000.0)

    private let luxColors: [(threshold: Double, color: NSColor)] = [
        (10, NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.30, alpha: 1)),
        (100, NSColor(calibratedRed: 0.30, green: 0.20, blue: 0.15, alpha: 1)),
        (400, NSColor(calibratedRed: 0.15, green: 0.30, blue: 0.40, alpha: 1)),
        (6400, NSColor(calibratedRed: 0.40, green: 0.50, blue: 0.60, alpha: 1)),
        (12800, NSColor(calibratedRed: 0.20, green: 0.55, blue: 0.50, alpha: 1)),
        (25600, NSColor(calibratedRed: 0.80, green: 0.50, blue: 0.25, alpha: 1)),
    ]

    init(settings: SettingsStore) {
        self.settings = settings
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 460))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindSettings()
    }

    private func setupUI() {
        let root = NSStackView()
        root.orientation = .vertical
        root.spacing = 0
        root.edgeInsets = NSEdgeInsets(top: 24, left: 28, bottom: 24, right: 28)
        root.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(root)

        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            root.topAnchor.constraint(equalTo: view.topAnchor),
            root.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])

        root.addArrangedSubview(makeTitle())
        root.setCustomSpacing(8, after: root.arrangedSubviews.last!)

        root.addArrangedSubview(makeLiveReading())
        root.setCustomSpacing(32, after: root.arrangedSubviews.last!)

        root.addArrangedSubview(makeThresholdSection())
        root.setCustomSpacing(24, after: root.arrangedSubviews.last!)

        root.addArrangedSubview(makeDebounceSection())
        root.setCustomSpacing(28, after: root.arrangedSubviews.last!)

        root.addArrangedSubview(makeActionButtons())
        root.setCustomSpacing(16, after: root.arrangedSubviews.last!)

        root.addArrangedSubview(makeLaunchAtLoginSection())
        root.setCustomSpacing(24, after: root.arrangedSubviews.last!)

        root.addArrangedSubview(makeFooter())
    }

    private func makeFooter() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 4
        stack.alignment = .centerX

        let label = NSTextField(labelWithString: "Enjoying Lumen?")
        label.font = NSFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = .secondaryLabelColor
        label.alignment = .center

        let link = NSButton(title: "Support on Ko-fi ☕", target: self, action: #selector(openKofiLink))
        link.bezelStyle = .inline
        link.font = NSFont.systemFont(ofSize: 11, weight: .regular)
        link.isBordered = false
        link.contentTintColor = NSColor(calibratedRed: 0.2, green: 0.5, blue: 0.8, alpha: 1)
        link.toolTip = "Support Lumen development on Ko-fi."

        stack.addArrangedSubview(label)
        stack.addArrangedSubview(link)
        return stack
    }

    @objc private func openKofiLink() {
        if let url = URL(string: "https://ko-fi.com/knightfolk") {
            NSWorkspace.shared.open(url)
        }
    }

    private func makeTitle() -> NSView {
        let imageView = NSImageView()
        for bundle in [Bundle.main] + Bundle.allBundles {
            if let url = bundle.url(forResource: "auto_light_mode_logo", withExtension: "png"),
               let image = NSImage(contentsOf: url) {
                imageView.image = image
                break
            }
        }
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 260),
            imageView.heightAnchor.constraint(equalToConstant: 65)
        ])
        return imageView
    }

    private func makeLiveReading() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 4
        stack.alignment = .centerX

        let header = NSTextField(labelWithString: "Current Measurement")
        header.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        header.textColor = .secondaryLabelColor
        header.alignment = .center

        luxValueLabel = NSTextField(labelWithString: "--")
        luxValueLabel.font = NSFont.monospacedSystemFont(ofSize: 48, weight: .bold)
        luxValueLabel.alignment = .center
        luxValueLabel.toolTip = "Current ambient light in lux (lx). Higher values mean brighter environments."

        let unitRow = NSStackView()
        unitRow.orientation = .horizontal
        unitRow.spacing = 6
        unitRow.alignment = .centerY

        luxLevelIndicator = NSView()
        luxLevelIndicator.wantsLayer = true
        luxLevelIndicator.layer?.cornerRadius = 4
        luxLevelIndicator.translatesAutoresizingMaskIntoConstraints = false
        luxLevelIndicator.toolTip = "Color indicates current light level — dark blue for dim, orange for bright."
        NSLayoutConstraint.activate([
            luxLevelIndicator.widthAnchor.constraint(equalToConstant: 8),
            luxLevelIndicator.heightAnchor.constraint(equalToConstant: 8)
        ])
        updateLuxIndicator(lux: nil)

        quickSetButton = NSButton(title: "Quick Set", target: self, action: #selector(quickSetButtonClicked))
        quickSetButton.bezelStyle = .roundRect
        quickSetButton.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        quickSetButton.isEnabled = false
        quickSetButton.toolTip = "Set the threshold to 90% of the current ambient light reading."

        unitRow.addArrangedSubview(luxLevelIndicator)
        unitRow.addArrangedSubview(quickSetButton)

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(luxValueLabel)
        stack.addArrangedSubview(unitRow)
        return stack
    }

    private func makeThresholdSection() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .centerX

        let header = NSTextField(labelWithString: "Threshold")
        header.font = NSFont.systemFont(ofSize: 15, weight: .semibold)
        header.alignment = .center

        let sliderRow = NSStackView()
        sliderRow.orientation = .horizontal
        sliderRow.spacing = 12
        sliderRow.alignment = .centerY

        thresholdSlider = NSSlider(value: sliderFromLux(settings.lightThreshold),
                                    minValue: 0, maxValue: 1,
                                    target: self, action: #selector(thresholdSliderChanged))
        thresholdSlider.allowsTickMarkValuesOnly = false
        thresholdSlider.translatesAutoresizingMaskIntoConstraints = false
        thresholdSlider.widthAnchor.constraint(equalToConstant: 200).isActive = true

        thresholdValueLabel = NSTextField(labelWithString: formatLux(settings.lightThreshold))
        thresholdValueLabel.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .medium)
        thresholdValueLabel.textColor = .secondaryLabelColor
        thresholdValueLabel.alignment = .right
        thresholdValueLabel.translatesAutoresizingMaskIntoConstraints = false
        thresholdValueLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true

        sliderRow.addArrangedSubview(thresholdSlider)
        sliderRow.addArrangedSubview(thresholdValueLabel)
        sliderRow.toolTip = "When ambient light exceeds this value, Lumen switches to Light appearance."

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(sliderRow)
        return stack
    }

    private func makeDebounceSection() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 10
        stack.alignment = .leading

        let header = NSTextField(labelWithString: "Delay")
        header.font = NSFont.systemFont(ofSize: 13, weight: .semibold)

        let buttonRow = NSStackView()
        buttonRow.orientation = .horizontal
        buttonRow.spacing = 16
        buttonRow.alignment = .centerY

        let options: [(label: String, value: Double)] = [
            ("5s", 5),
            ("10s", 10),
            ("20s", 20)
        ]

        for (label, value) in options {
            let btn = NSButton(radioButtonWithTitle: label, target: self, action: #selector(debounceButtonClicked(_:)))
            btn.tag = Int(value)
            debounceButtons.append(btn)
            buttonRow.addArrangedSubview(btn)
        }
        buttonRow.toolTip = "Wait time before switching appearance. Prevents rapid toggling from brief light changes."

        updateDebounceSelection()

        stack.addArrangedSubview(header)
        stack.addArrangedSubview(buttonRow)
        return stack
    }

    private func makeLaunchAtLoginSection() -> NSView {
        let checkbox = NSButton(checkboxWithTitle: "Launch at Login", target: self, action: #selector(launchAtLoginToggled))
        checkbox.state = settings.launchAtLogin ? .on : .off
        checkbox.font = NSFont.systemFont(ofSize: 13, weight: .regular)
        launchAtLoginCheckbox = checkbox
        return checkbox
    }

    @objc private func launchAtLoginToggled() {
        settings.launchAtLogin = (launchAtLoginCheckbox.state == .on)
    }

    private func makeActionButtons() -> NSView {
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually

        autoButton = NSButton(title: autoButtonTitle(), target: self, action: #selector(autoButtonClicked))
        autoButton.bezelStyle = .roundRect
        autoButton.toolTip = "Resume automatic light/dark switching after pausing."

        let quit = NSButton(title: "Quit", target: self, action: #selector(quitButtonClicked))
        quit.bezelStyle = .roundRect

        stack.addArrangedSubview(autoButton)
        stack.addArrangedSubview(quit)
        return stack
    }

    private func autoButtonTitle() -> String {
        settings.enableAutoSwitch ? "Active" : "Unpause"
    }

    private func updateLuxIndicator(lux: Double?) {
        guard let lux else {
            luxLevelIndicator.layer?.backgroundColor = NSColor.separatorColor.cgColor
            return
        }
        let color = luxColor(for: lux)
        luxLevelIndicator.layer?.backgroundColor = color.cgColor
    }

    private func luxColor(for lux: Double) -> NSColor {
        for (threshold, color) in luxColors.reversed() {
            if lux >= threshold { return color }
        }
        return luxColors[0].color
    }

    private func luxFromSlider(_ value: Double) -> Double {
        let logValue = minLog + value * (maxLog - minLog)
        return pow(10.0, logValue)
    }

    private func sliderFromLux(_ lux: Double) -> Double {
        let logValue = log10(lux)
        return (logValue - minLog) / (maxLog - minLog)
    }

    private func formatLux(_ lux: Double) -> String {
        if lux >= 1000 {
            return String(format: "%.1fk", lux / 1000)
        }
        return String(format: "%.0f", lux)
    }

    @objc private func thresholdSliderChanged() {
        settings.lightThreshold = luxFromSlider(thresholdSlider.doubleValue)
    }

    @objc private func debounceButtonClicked(_ sender: NSButton) {
        settings.debounceDuration = Double(sender.tag)
    }

    private func updateDebounceSelection() {
        let current = settings.debounceDuration
        for btn in debounceButtons {
            btn.state = (Double(btn.tag) == current) ? .on : .off
        }
    }

    @objc private func autoButtonClicked() {
        let newValue = !settings.enableAutoSwitch
        settings.enableAutoSwitch = newValue
        actionDelegate?.settingsViewControllerDidToggleAutoSwitch(newValue)
    }

    @objc private func quickSetButtonClicked() {
        guard let reading = currentReading else { return }
        let adjusted = floor(reading.lux * 0.9 / 100) * 100
        let clamped = max(minLux, min(adjusted, maxLux))
        settings.lightThreshold = clamped
    }

    @objc private func quitButtonClicked() {
        actionDelegate?.settingsViewControllerDidRequestQuit()
    }

    private func bindSettings() {
        settings.$lightThreshold
            .sink { [weak self] value in
                self?.thresholdSlider?.doubleValue = self?.sliderFromLux(value) ?? 0
                self?.thresholdValueLabel?.stringValue = self?.formatLux(value) ?? ""
            }
            .store(in: &cancellables)

        settings.$debounceDuration
            .sink { [weak self] _ in
                self?.updateDebounceSelection()
            }
            .store(in: &cancellables)

        settings.$enableAutoSwitch
            .sink { [weak self] _ in
                self?.autoButton?.title = self?.autoButtonTitle() ?? "Auto"
            }
            .store(in: &cancellables)

        settings.$launchAtLogin
            .sink { [weak self] enabled in
                self?.launchAtLoginCheckbox?.state = enabled ? .on : .off
            }
            .store(in: &cancellables)
    }

    func updateCurrentReading(_ reading: ALSReading?) {
        guard isViewLoaded else { return }
        currentReading = reading
        quickSetButton?.isEnabled = (reading != nil)

        guard let reading else {
            luxValueLabel?.stringValue = "--"
            updateLuxIndicator(lux: nil)
            return
        }
        luxValueLabel?.stringValue = String(format: "%.0f", reading.lux)
        updateLuxIndicator(lux: reading.lux)
    }
}
