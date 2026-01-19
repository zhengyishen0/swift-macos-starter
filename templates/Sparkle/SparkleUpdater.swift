import Cocoa
import Sparkle

/// Manages Sparkle auto-updates for the app.
///
/// Setup:
/// 1. Add Sparkle SPM package to your project
/// 2. Configure Info.plist with SUFeedURL, SUPublicEDKey, SUEnableAutomaticChecks
/// 3. Initialize this in AppDelegate and pass updater to StatusBarController
///
/// Usage in AppDelegate:
/// ```swift
/// private var updaterController: SPUStandardUpdaterController!
///
/// func applicationDidFinishLaunching(_ notification: Notification) {
///     updaterController = SPUStandardUpdaterController(
///         startingUpdater: true,
///         updaterDelegate: nil,
///         userDriverDelegate: nil
///     )
///     statusBarController = StatusBarController(updater: updaterController.updater, ...)
/// }
/// ```
///
/// Usage in StatusBarController:
/// ```swift
/// private let updater: SPUUpdater
///
/// init(updater: SPUUpdater, ...) {
///     self.updater = updater
///     ...
/// }
///
/// // Add menu item
/// let updateItem = NSMenuItem(title: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
/// updateItem.target = self
/// menu.addItem(updateItem)
///
/// @objc private func checkForUpdates() {
///     updater.checkForUpdates()
/// }
/// ```
