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
        let keyEquivalent: String
    }

    private let tools: [ToolItem] = [
        ToolItem(name: "Claude", symbolName: "sparkles", command: "claude --dangerously-skip-permissions", keyEquivalent: "1"),
        ToolItem(name: "Codex", symbolName: "chevron.left.forwardslash.chevron.right", command: "codex", keyEquivalent: "2"),
        ToolItem(name: "Kimi", symbolName: "brain.head.profile", command: "kimi-cli", keyEquivalent: "3"),
        ToolItem(name: "Gemini", symbolName: "circle.hexagongrid", command: "gemini", keyEquivalent: "4"),
    ]

    public override init() {
        super.init()
    }

    public func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        registerGlobalHotKey()
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

        item.button?.toolTip = "TermBar — Launch CLI tools"
        item.menu = buildMenu()
        statusItem = item
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        for tool in tools {
            let menuItem = NSMenuItem(
                title: tool.name,
                action: #selector(toolMenuItemClicked(_:)),
                keyEquivalent: tool.keyEquivalent
            )
            menuItem.keyEquivalentModifierMask = .command
            menuItem.target = self
            menuItem.representedObject = tool.command

            if let image = NSImage(systemSymbolName: tool.symbolName, accessibilityDescription: tool.name) {
                image.isTemplate = true
                menuItem.image = image
            }

            menu.addItem(menuItem)
        }

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit TermBar", action: #selector(quitApp), keyEquivalent: "q")
        quit.keyEquivalentModifierMask = .command
        quit.target = self
        menu.addItem(quit)

        return menu
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

    // MARK: - Global Hot Key

    private func registerGlobalHotKey() {
        // Ctrl+Opt+T  (keyCode 17 = kVK_ANSI_T)
        let modifiers = UInt32(controlKey | optionKey)
        let keyCode = UInt32(kVK_ANSI_T)

        let registered = hotKeyManager.register(keyCode: keyCode, modifiers: modifiers) { [weak self] in
            DispatchQueue.main.async {
                self?.statusItem?.button?.performClick(nil)
            }
        }

        if !registered {
            NSLog("TermBar: Failed to register global hotkey Ctrl+Opt+T")
        }
    }
}
