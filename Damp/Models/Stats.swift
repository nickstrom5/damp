import Foundation

/// Everything derived from the log. Recomputed whenever the log or the answers change; never
/// stored, so it can't drift from the source of truth.
struct Stats: Equatable {
    var streak = 0
    var longestStreak = 0
    var dryNights = 0
    var loggedNights = 0
    var drinksLogged = 0
    /// Drinks not had, versus the user's stated baseline, across every logged night.
    var drinksSkipped: Double = 0
    var moneySaved: Double = 0
    var caloriesSkipped = 0

    /// Streak lengths worth a card. Reached once each.
    static let milestones = [1, 3, 7, 14, 30, 60, 100, 365]

    static func compute(logs: [DayLog], answers: OnboardingAnswers, today: Date = Date(), calendar cal: Calendar = .current) -> Stats {
        var byDay: [Date: Int] = [:]
        for log in logs { byDay[cal.startOfDay(for: log.day)] = log.drinks }
        let days = byDay.keys.sorted()

        var stats = Stats()
        stats.loggedNights = days.count
        stats.dryNights = byDay.values.filter { $0 == 0 }.count
        stats.drinksLogged = byDay.values.reduce(0, +)

        // Longest run of consecutive dry days anywhere in the log.
        var run = 0
        var previous: Date?
        for day in days {
            if byDay[day] == 0 {
                if let previous, let next = cal.date(byAdding: .day, value: 1, to: previous), cal.isDate(next, inSameDayAs: day) {
                    run += 1
                } else {
                    run = 1
                }
            } else {
                run = 0
            }
            stats.longestStreak = max(stats.longestStreak, run)
            previous = day
        }

        // Current streak: counts back from today if tonight is logged, else from yesterday, so
        // an unlogged evening doesn't zero the number before the user has had a chance to tap.
        var cursor = cal.startOfDay(for: today)
        if byDay[cursor] == nil, let yesterday = cal.date(byAdding: .day, value: -1, to: cursor) {
            cursor = yesterday
        }
        while let drinks = byDay[cursor], drinks == 0, let earlier = cal.date(byAdding: .day, value: -1, to: cursor) {
            stats.streak += 1
            cursor = earlier
        }

        let expected = answers.baselineDrinksPerDay * Double(stats.loggedNights)
        stats.drinksSkipped = max(0, expected - Double(stats.drinksLogged))
        stats.moneySaved = stats.drinksSkipped * answers.pricePerDrink
        stats.caloriesSkipped = Int((stats.drinksSkipped * Double(OnboardingAnswers.caloriesPerDrink)).rounded())
        return stats
    }

    // MARK: - Formatting

    var moneySavedFormatted: String { Self.money(moneySaved) }

    static func money(_ value: Double) -> String {
        let rounded = value.rounded()
        return rounded.formatted(.currency(code: "USD").precision(.fractionLength(0)))
    }

    static func calories(_ value: Int) -> String {
        value.formatted(.number.grouping(.automatic))
    }
}
