import Foundation

/// One night, logged. `drinks == 0` is a dry night. Nights never logged don't exist; we only
/// count what the user told us.
struct DayLog: Codable, Equatable, Identifiable {
    /// Start of the calendar day the night belongs to.
    var day: Date
    var drinks: Int
    var loggedAt: Date = Date()

    var id: Date { day }
    var isDry: Bool { drinks == 0 }
}

/// How one day shows in the week strip on the home screen.
enum DayStatus: Equatable {
    case dry
    case drank(Int)
    /// A past day the user never logged.
    case missed
    /// Today, not logged yet.
    case today
    case future
}

struct WeekDay: Identifiable, Equatable {
    let date: Date
    let status: DayStatus
    var id: Date { date }
}
