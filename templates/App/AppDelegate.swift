//
//  AppDelegate.swift
//  __APP_NAME__
//
//  Main application delegate for menu bar app.
//

import Cocoa
// Uncomment for Sparkle auto-updates:
// import Sparkle

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusBarController: StatusBarController!

    // Uncomment for Sparkle auto-updates:
    // private var updaterController: SPUStandardUpdaterController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Uncomment for Sparkle auto-updates:
        // updaterController = SPUStandardUpdaterController(
        //     startingUpdater: true,
        //     updaterDelegate: nil,
        //     userDriverDelegate: nil
        // )

        // Initialize status bar controller
        // With Sparkle:
        // statusBarController = StatusBarController(updater: updaterController.updater)
        // Without Sparkle:
        statusBarController = StatusBarController()

        // Uncomment for License system - check on startup:
        // if !LicenseManager.shared.canUseApp {
        //     LicenseWindowController.shared.showLicenseWindow()
        // }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
