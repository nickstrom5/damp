import Foundation
import os

/// Every funnel event the business is judged on. Names are stable so the backend can change.
enum AnalyticsEvent: String {
    case appOpen = "app_open"
    case onboardingStarted = "onboarding_started"
    case onboardingStep = "onboarding_step"
    case onboardingCompleted = "onboarding_completed"
    case remindersAuthorized = "reminders_authorized"
    case remindersDenied = "reminders_denied"
    case firstNightLogged = "first_night_logged"
    case firstNightSkipped = "first_night_skipped"
    case paywallShown = "paywall_shown"
    case paywallDismissed = "paywall_dismissed"
    case planSelected = "plan_selected"
    case trialStarted = "trial_started"
    case paid = "paid"
    case purchaseCancelled = "purchase_cancelled"
    case purchaseFailed = "purchase_failed"
    case restoreTapped = "restore_tapped"
    case storeLoadFailed = "store_load_failed"
    case nightLogged = "night_logged"
    case nightChanged = "night_changed"
    case milestoneReached = "milestone_reached"
    case shareTapped = "share_tapped"
    case reminderTimeChanged = "reminder_time_changed"
}

protocol AnalyticsSink {
    func track(_ event: AnalyticsEvent, _ properties: [String: Any])
}

/// `DampApp.init` installs the console sink plus PostHog when `Config.postHogKey` is set.
enum Analytics {
    static var sink: AnalyticsSink = ConsoleAnalytics()

    static func track(_ event: AnalyticsEvent, _ properties: [String: Any] = [:]) {
        sink.track(event, properties)
    }
}

struct ConsoleAnalytics: AnalyticsSink {
    private let log = Logger(subsystem: "app.usedamp.damp", category: "analytics")

    func track(_ event: AnalyticsEvent, _ properties: [String: Any]) {
        let props = properties.isEmpty ? "" : " \(properties)"
        log.info("\(event.rawValue, privacy: .public)\(props, privacy: .public)")
    }
}
