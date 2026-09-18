import Foundation
import UIKit

/// Launch the app with `-screenshot <screen>` to open one screen with seeded data.
/// Used by `.github/workflows/screenshots.yml` to capture every screen in the simulator, and
/// handy for App Store screenshots. Never active in a normal launch.
enum ScreenshotMode {
    enum Screen: String, CaseIterable {
        case hook, drinks, price, reasons, reveal, goal, first, result, paywall
        case home, log, milestone, settings, share
    }

    static let screen: Screen? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-screenshot"), i + 1 < args.count else { return nil }
        return Screen(rawValue: args[i + 1])
    }()

    static var isActive: Bool { screen != nil }

    /// Fills the app with believable data so screens don't look empty.
    @MainActor
    static func seed(_ appState: AppState) {
        UIView.setAnimationsEnabled(false)
        var answers = OnboardingAnswers()
        answers.drinksPerWeek = 10
        answers.pricePerDrink = 8
        answers.reasons = [.sleep, .money, .hangxiety]
        answers.dryNightsGoal = 4
        appState.answers = answers

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // 12 dry nights in a row, two drinking nights before that. Tonight not logged yet.
        var logs: [DayLog] = []
        for daysAgo in 1...12 {
            logs.append(DayLog(day: cal.date(byAdding: .day, value: -daysAgo, to: today)!, drinks: 0))
        }
        logs.append(DayLog(day: cal.date(byAdding: .day, value: -13, to: today)!, drinks: 3))
        logs.append(DayLog(day: cal.date(byAdding: .day, value: -14, to: today)!, drinks: 2))
        if screen == .first || screen == .result {
            logs = []
        }
        if screen == .result {
            logs = [DayLog(day: today, drinks: 0)]
        }
        appState.replaceLogs(logs, celebrated: [1, 3, 7])
        appState.hasCompletedOnboarding = {
            switch screen {
            case .home, .log, .milestone, .settings, .share: return true
            default: return false
            }
        }()
    }
}
