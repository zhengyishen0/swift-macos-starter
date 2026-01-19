//
//  LicenseManager.swift
//  __APP_NAME__
//
//  License management with weekly rotating tokens.
//  Configure the keywords array and UserDefaults keys for your app.
//

import Foundation

class LicenseManager {

    static let shared = LicenseManager()

    // MARK: - Configuration (Customize these for your app)

    private let licenseKey = "__APP_NAME__LicenseKey"
    private let firstLaunchKey = "__APP_NAME__FirstLaunchDate"
    private let trialDays = 7

    // 12 base keywords - sliding window of 4 creates weekly tokens
    // Customize these with words related to your app's theme
    private let words = [
        "WORD1", "WORD2", "WORD3", "WORD4",
        "WORD5", "WORD6", "WORD7", "WORD8",
        "WORD9", "WORD10", "WORD11", "WORD12"
    ]

    // MARK: - Initialization

    init() {
        // Record first launch date if not set
        if UserDefaults.standard.object(forKey: firstLaunchKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchKey)
        }
    }

    // MARK: - Public Properties

    /// Check if app is licensed
    var isLicensed: Bool {
        return UserDefaults.standard.string(forKey: licenseKey) != nil
    }

    /// Get stored license key
    var storedLicense: String? {
        return UserDefaults.standard.string(forKey: licenseKey)
    }

    /// Check if trial is still active
    var isTrialActive: Bool {
        return trialDaysRemaining > 0
    }

    /// Get remaining trial days
    var trialDaysRemaining: Int {
        guard let firstLaunch = UserDefaults.standard.object(forKey: firstLaunchKey) as? Date else {
            return trialDays
        }
        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunch, to: Date()).day ?? 0
        return max(0, trialDays - daysSinceFirstLaunch)
    }

    /// Check if app can be used (licensed OR trial active)
    var canUseApp: Bool {
        return isLicensed || isTrialActive
    }

    /// Get status text for display
    var statusText: String {
        if isLicensed {
            return "Licensed"
        } else if isTrialActive {
            let days = trialDaysRemaining
            return days == 1 ? "Trial: 1 day left" : "Trial: \(days) days left"
        } else {
            return "Trial expired"
        }
    }

    // MARK: - Public Methods

    /// Validate and store a license key
    /// Returns true if valid, false otherwise
    func activate(key: String) -> Bool {
        let cleanKey = key.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if isValidToken(cleanKey) {
            UserDefaults.standard.set(cleanKey, forKey: licenseKey)
            return true
        }
        return false
    }

    /// Remove stored license
    func deactivate() {
        UserDefaults.standard.removeObject(forKey: licenseKey)
    }

    // MARK: - Token Generation

    /// Generate token for a given week number (1-52)
    private func getTokenForWeek(_ weekNum: Int) -> String {
        let startIndex = (weekNum - 1) % 12
        var tokenWords: [String] = []
        for i in 0..<4 {
            tokenWords.append(words[(startIndex + i) % 12])
        }
        return tokenWords.joined(separator: "-")
    }

    /// Get ISO week number from date
    private func getWeekNumber(from date: Date) -> Int {
        let calendar = Calendar(identifier: .iso8601)
        return calendar.component(.weekOfYear, from: date)
    }

    // MARK: - Validation

    /// Check if token is valid (current week or previous week)
    private func isValidToken(_ token: String) -> Bool {
        let currentWeek = getWeekNumber(from: Date())

        // Generate valid tokens: current week + 1 previous week
        var validTokens: [String] = []
        for i in 0..<2 {
            var week = currentWeek - i
            // Handle year boundary (week 0 or negative = previous year's weeks)
            if week <= 0 {
                week += 52
            }
            validTokens.append(getTokenForWeek(week))
        }

        return validTokens.contains(token)
    }

    // MARK: - Debug Helpers

    /// Get current week's token (for testing/debug)
    func getCurrentToken() -> String {
        let currentWeek = getWeekNumber(from: Date())
        return getTokenForWeek(currentWeek)
    }

    /// Get all currently valid tokens (for testing/debug)
    func getValidTokens() -> [String] {
        let currentWeek = getWeekNumber(from: Date())
        var tokens: [String] = []
        for i in 0..<2 {
            var week = currentWeek - i
            if week <= 0 {
                week += 52
            }
            tokens.append(getTokenForWeek(week))
        }
        return tokens
    }
}
