import AppKit
import OSLog

public protocol MenuBarControllerDelegate: AnyObject {
    func menuBarControllerDidRequestEnableAutoSwitch()
    func menuBarControllerDidRequestQuit()
    func currentAppearanceMode() -> AppearanceMode
}

public final class MenuBarController: NSObject {
    private var statusItem: NSStatusItem!
    private let settings: SettingsStore
    private let logger = Logger(subsystem: "com.lumen.app", category: "MenuBarController")
    public weak var delegate: MenuBarControllerDelegate?

    private var popover: NSPopover!
    private var settingsViewController: SettingsViewController!
    private var eventMonitor: Any?

    public init(settings: SettingsStore) {
        self.settings = settings
        super.init()
        setupStatusItem()
        setupPopover()
        setupEventMonitor()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem.button else { return }
        button.image = StatusBarIcon.image(for: .dark)
        button.action = #selector(statusBarButtonClicked)
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func setupPopover() {
        settingsViewController = SettingsViewController(settings: settings)
        settingsViewController.actionDelegate = self
        popover = NSPopover()
        popover.contentViewController = settingsViewController
        popover.behavior = .transient
    }

    private func setupEventMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePopover()
        }
    }

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            showMinimalMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem.button else { return }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }

    private func closePopover() {
        popover.close()
    }

    private func showMinimalMenu() {
        let menu = NSMenu()

        let modeItem = NSMenuItem(
            title: "Currently: \(delegate?.currentAppearanceMode().displayName ?? "Unknown")",
            action: nil,
            keyEquivalent: ""
        )
        modeItem.isEnabled = false
        menu.addItem(modeItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit Lumen",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func quitApp() {
        delegate?.menuBarControllerDidRequestQuit()
    }

    public func updateIcon(for mode: AppearanceMode) {
        guard let button = statusItem.button else { return }
        button.image = StatusBarIcon.image(for: mode)
        settingsViewController?.updateModeStatus(mode)
    }

    public func updateCurrentReading(_ reading: ALSReading?) {
        settingsViewController?.updateCurrentReading(reading)
    }

    public func showAutoModeDisabledNotice() {
        logger.info("macOS Auto Mode was active — Lumen has disabled it to prevent conflicts")
    }
}

extension MenuBarController: SettingsViewControllerActionDelegate {
    func settingsViewControllerDidToggleAutoSwitch(_ isEnabled: Bool) {
        if isEnabled {
            delegate?.menuBarControllerDidRequestEnableAutoSwitch()
        }
    }

    func settingsViewControllerDidRequestQuit() {
        delegate?.menuBarControllerDidRequestQuit()
    }
}
