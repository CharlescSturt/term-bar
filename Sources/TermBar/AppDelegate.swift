import AppKit
import Carbon
import Foundation

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private let hotKeyManager = GlobalHotKeyManager()
    private var statusItem: NSStatusItem?

    private struct ToolItem {
        let name: String
        let symbolName: String
        let command: String
        let keyCode: UInt32
        let shortcutLabel: String
    }

    private let tools: [ToolItem] = [
        ToolItem(name: "Claude", symbolName: "sparkles", command: "claude --dangerously-skip-permissions", keyCode: UInt32(kVK_ANSI_1), shortcutLabel: "Ctrl+Opt+1"),
        ToolItem(name: "Codex", symbolName: "chevron.left.forwardslash.chevron.right", command: "codex", keyCode: UInt32(kVK_ANSI_2), shortcutLabel: "Ctrl+Opt+2"),
        ToolItem(name: "Kimi", symbolName: "brain.head.profile", command: "kimi-cli", keyCode: UInt32(kVK_ANSI_3), shortcutLabel: "Ctrl+Opt+3"),
        ToolItem(name: "Gemini", symbolName: "circle.hexagongrid", command: "gemini", keyCode: UInt32(kVK_ANSI_4), shortcutLabel: "Ctrl+Opt+4"),
    ]

    public override init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        registerGlobalHotKeys()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        hotKeyManager.unregisterAll()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let image = NSImage(systemSymbolName: "terminal.fill", accessibilityDescription: "TermBar") {
            image.isTemplate = true
            item.button?.image = image
        } else {
            item.button?.title = "TB"
        }

        item.button?.toolTip = """
        TermBar — Launch CLI tools
        ⌃⌥T  Open this menu
        ⌃⌥1  Claude
        ⌃⌥2  Codex
        ⌃⌥3  Kimi
        ⌃⌥4  Gemini
        """
        item.menu = buildMenu()
        statusItem = item
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        for tool in tools {
            let menuItem = NSMenuItem(
                title: tool.name,
                action: #selector(toolMenuItemClicked(_:)),
                keyEquivalent: ""
            )
            menuItem.target = self
            menuItem.representedObject = tool.command

            // Custom view with logo, name left, shortcut right
            let width: CGFloat = 280
            let container = ClickableMenuItemView(frame: NSRect(x: 0, y: 0, width: width, height: 28))
            container.menuItem = menuItem

            let logoImage = ToolLogos.logo(for: tool.name, size: 16)
            let logoView = NSImageView(frame: NSRect(x: 12, y: 6, width: 16, height: 16))
            logoView.image = logoImage
            logoView.imageScaling = .scaleProportionallyUpOrDown
            container.addSubview(logoView)

            let nameField = NSTextField(labelWithString: tool.name)
            nameField.font = NSFont.menuFont(ofSize: 14)
            nameField.textColor = .labelColor
            nameField.frame = NSRect(x: 34, y: 5, width: 120, height: 18)
            container.addSubview(nameField)

            let shortcutField = NSTextField(labelWithString: tool.shortcutLabel)
            shortcutField.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            shortcutField.textColor = .secondaryLabelColor
            shortcutField.alignment = .right
            shortcutField.frame = NSRect(x: width - 120, y: 5, width: 110, height: 18)
            container.addSubview(shortcutField)

            menuItem.view = container
            menu.addItem(menuItem)
        }

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit TermBar", action: #selector(quitApp), keyEquivalent: "q")
        quit.keyEquivalentModifierMask = .command
        quit.target = self
        menu.addItem(quit)

        return menu
    }

    // MARK: - Clickable Menu Item View

    private class ClickableMenuItemView: NSView {
        weak var menuItem: NSMenuItem?
        private var isHighlighted = false
        private var trackingArea: NSTrackingArea?

        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            if let existing = trackingArea { removeTrackingArea(existing) }
            let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInActiveApp], owner: self)
            addTrackingArea(area)
            trackingArea = area
        }

        override func draw(_ dirtyRect: NSRect) {
            if isHighlighted {
                NSColor.selectedContentBackgroundColor.setFill()
                NSBezierPath(roundedRect: bounds.insetBy(dx: 4, dy: 1), xRadius: 4, yRadius: 4).fill()
                // Update text colors when highlighted
                for subview in subviews {
                    if let tf = subview as? NSTextField {
                        tf.textColor = .white
                    }
                }
            } else {
                for subview in subviews {
                    if let tf = subview as? NSTextField {
                        if tf.alignment == .right {
                            tf.textColor = .secondaryLabelColor
                        } else {
                            tf.textColor = .labelColor
                        }
                    }
                }
            }
        }

        override func mouseEntered(with event: NSEvent) {
            isHighlighted = true
            needsDisplay = true
        }

        override func mouseExited(with event: NSEvent) {
            isHighlighted = false
            needsDisplay = true
        }

        override func mouseUp(with event: NSEvent) {
            guard let menuItem, let menu = menuItem.menu else { return }
            menu.cancelTracking()
            _ = menuItem.target?.perform(menuItem.action, with: menuItem)
        }
    }

    // MARK: - Actions

    @objc private func toolMenuItemClicked(_ sender: NSMenuItem) {
        guard let command = sender.representedObject as? String else { return }
        launchInTerminal(command: command)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Terminal Launch

    private func launchInTerminal(command: String) {
        let tmpDir = FileManager.default.temporaryDirectory
        let scriptURL = tmpDir.appendingPathComponent("termbar-\(UUID().uuidString).command")
        let content = """
        #!/bin/bash
        clear
        exec \(command)
        """
        do {
            try content.write(to: scriptURL, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes(
                [.posixPermissions: 0o755],
                ofItemAtPath: scriptURL.path
            )
            NSWorkspace.shared.open(scriptURL)
        } catch {
            NSSound.beep()
        }
    }

    // MARK: - Global Hot Keys

    private func registerGlobalHotKeys() {
        let modifiers = UInt32(controlKey | optionKey)

        // Ctrl+Opt+T to open menu
        _ = hotKeyManager.register(keyCode: UInt32(kVK_ANSI_T), modifiers: modifiers) { [weak self] in
            DispatchQueue.main.async {
                self?.statusItem?.button?.performClick(nil)
            }
        }

        // Ctrl+Opt+1/2/3/4 to launch tools directly
        for tool in tools {
            let command = tool.command
            _ = hotKeyManager.register(keyCode: tool.keyCode, modifiers: modifiers) { [weak self] in
                DispatchQueue.main.async {
                    self?.launchInTerminal(command: command)
                }
            }
        }
    }
}
