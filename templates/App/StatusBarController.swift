//
//  StatusBarController.swift
//  __APP_NAME__
//
//  Menu bar controller with status item and dropdown menu.
//

import Cocoa
// Uncomment for Sparkle auto-updates:
// import Sparkle

class StatusBarController {

    private var statusItem: NSStatusItem!
    private var menu: NSMenu!

    // Uncomment for Sparkle auto-updates:
    // private let updater: SPUUpdater
    //
    // init(updater: SPUUpdater) {
    //     self.updater = updater
    //     setupStatusBar()
    // }

    init() {
        setupStatusBar()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Use SF Symbol for menu bar icon (isTemplate for dark/light mode)
            if let image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "__APP_NAME__") {
                image.isTemplate = true
                button.image = image
            }
        }

        setupMenu()
    }

    private func setupMenu() {
        menu = NSMenu()

        // App name header
        let headerItem = NSMenuItem(title: "__APP_NAME__", action: nil, keyEquivalent: "")
        headerItem.isEnabled = false
        menu.addItem(headerItem)

        menu.addItem(NSMenuItem.separator())

        // Main action item
        let actionItem = NSMenuItem(title: "Do Something", action: #selector(doSomething), keyEquivalent: "")
        actionItem.target = self
        menu.addItem(actionItem)

        menu.addItem(NSMenuItem.separator())

        // Uncomment for License system:
        // let licenseItem = NSMenuItem(title: LicenseManager.shared.statusText, action: #selector(showLicense), keyEquivalent: "")
        // licenseItem.target = self
        // menu.addItem(licenseItem)

        // Uncomment for Sparkle auto-updates:
        // let updateItem = NSMenuItem(title: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
        // updateItem.target = self
        // menu.addItem(updateItem)

        // About
        let aboutItem = NSMenuItem(title: "About __APP_NAME__", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit __APP_NAME__", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    // MARK: - Actions

    @objc private func doSomething() {
        // Your main app action
        print("Action triggered")
    }

    // Uncomment for License system:
    // @objc private func showLicense() {
    //     LicenseWindowController.shared.showLicenseWindow()
    // }

    // Uncomment for Sparkle auto-updates:
    // @objc private func checkForUpdates() {
    //     updater.checkForUpdates()
    // }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
