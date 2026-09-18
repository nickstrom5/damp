import Foundation
import SwiftUI
import WidgetKit

/// Small, persisted app state. Everything here is local; there is no backend in v1.
@MainActor
final class AppState: ObservableObject {
    private let defaults = AppGroup.defaults
    private let cal = Calendar.current

    @Published var hasCompletedOnboarding: Bool {
        didSet { defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    @Published var answers: OnboardingAnswers {
        didSet {
            save(answers, forKey: "onboardingAnswers")
            recompute()
        }
    }

    /// Every night the user has logged, one entry per day, oldest first.
    @Published private(set) var logs: [DayLog] {
        didSet {
            save(logs, forKey: "logs")
            recompute()
        }
    }

    @Published private(set) var stats = Stats()

    /// Nightly check-in time as minutes after midnight. Default 9:00 PM.
    @Published var reminderMinutes: Int {
        didSet { defaults.set(reminderMinutes, forKey: "reminderMinutes") }
    }

    /// Streak milestones already shown as a card, so each one fires once.
    @Published private(set) var celebratedMilestones: Set<Int> {
        didSet { save(Array(celebratedMilestones), forKey: "celebratedMilestones") }
    }

    /// Set when a dry night pushes the streak onto a milestone. Home presents the card.
    @Published var pendingMilestone: Int?

    /// The most recent log written this session, for result screens.
    @Published var lastLogged: DayLog?

    init() {
        hasCompletedOnboarding = defaults.bool(forKey: "hasCompletedOnboarding")
        answers = Self.load(OnboardingAnswers.self, forKey: "onboardingAnswers", from: defaults) ?? OnboardingAnswers()
        logs = Self.load([DayLog].self, forKey: "logs", from: defaults) ?? []
        let minutes = defaults.object(forKey: "reminderMinutes") as? Int
        reminderMinutes = minutes ?? 21 * 60
        celebratedMilestones = Set(Self.load([Int].self, forKey: "celebratedMilestones", from: defaults) ?? [])
        recompute()
    }

    // MARK: - Logging

    /// Upserts one night. `drinks == 0` is a dry night. Returns the stored entry.
    @discardableResult
    func log(day: Date = Date(), drinks: Int, source: String) -> DayLog {
        let start = cal.startOfDay(for: day)
        let entry = DayLog(day: start, drinks: max(0, drinks))
        let existed = logs.contains { cal.isDate($0.day, inSameDayAs: start) }

        var updated = logs.filter { !cal.isDate($0.day, inSameDayAs: start) }
        updated.append(entry)
        updated.sort { $0.day < $1.day }
        if updated.count > 2_000 { updated.removeFirst(updated.count - 2_000) }
        logs = updated
        lastLogged = entry

        Analytics.track(existed ? .nightChanged : .nightLogged,
                        ["dry": entry.isDry, "drinks": entry.drinks, "source": source])

        if entry.isDry, Stats.milestones.contains(stats.streak), !celebratedMilestones.contains(stats.streak) {
            celebratedMilestones.insert(stats.streak)
            pendingMilestone = stats.streak
            Analytics.track(.milestoneReached, ["streak": stats.streak])
        }
        return entry
    }

    func log(for day: Date) -> DayLog? {
        logs.first { cal.isDate($0.day, inSameDayAs: day) }
    }

    var todayLog: DayLog? { log(for: Date()) }

    var yesterday: Date { cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: Date()))! }

    var yesterdayLog: DayLog? { log(for: yesterday) }

    /// True when there is history before yesterday but yesterday itself was never logged.
    var yesterdayMissed: Bool {
        guard yesterdayLog == nil, let first = logs.first else { return false }
        return first.day < yesterday
    }

    /// The current calendar week, in the user's locale, with a status per day.
    var thisWeek: [WeekDay] {
        let today = cal.startOfDay(for: Date())
        guard let start = cal.dateInterval(of: .weekOfYear, for: today)?.start else { return [] }
        return (0..<7).compactMap { offset in
            guard let date = cal.date(byAdding: .day, value: offset, to: start) else { return nil }
            let status: DayStatus
            if let entry = log(for: date) {
                status = entry.isDry ? .dry : .drank(entry.drinks)
            } else if cal.isDate(date, inSameDayAs: today) {
                status = .today
            } else if date < today {
                status = .missed
            } else {
                status = .future
            }
            return WeekDay(date: date, status: status)
        }
    }

    var dryNightsThisWeek: Int {
        thisWeek.filter { $0.status == .dry }.count
    }

    /// Reads and clears the flag left behind by the widget / Siri intent, logging tonight dry.
    func consumePendingIntent() {
        guard defaults.bool(forKey: AppGroup.Key.pendingDryNight) else { return }
        defaults.removeObject(forKey: AppGroup.Key.pendingDryNight)
        guard hasCompletedOnboarding, todayLog == nil else { return }
        log(drinks: 0, source: "intent")
    }

    // MARK: - Derived

    private func recompute() {
        stats = Stats.compute(logs: logs, answers: answers)
        mirrorToWidget()
    }

    private func mirrorToWidget() {
        defaults.set(stats.streak, forKey: AppGroup.Key.streak)
        defaults.set(stats.moneySaved, forKey: AppGroup.Key.moneySaved)
        if let last = logs.last {
            defaults.set(AppGroup.dayFormatter.string(from: last.day), forKey: AppGroup.Key.lastLoggedDay)
            defaults.set(last.drinks, forKey: AppGroup.Key.lastLoggedDrinks)
        } else {
            defaults.removeObject(forKey: AppGroup.Key.lastLoggedDay)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Persistence helpers

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, forKey key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Test / screenshot seeding

    func replaceLogs(_ newLogs: [DayLog], celebrated: Set<Int> = []) {
        celebratedMilestones = celebrated
        logs = newLogs.sorted { $0.day < $1.day }
    }
}
