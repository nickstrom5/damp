import Foundation

/// Constants shared between the app and the widget extension.
enum AppGroup {
    static let identifier = "group.app.usedamp.damp"

    /// UserDefaults suite shared across the app and its extensions.
    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }

    enum Key {
        /// Current dry-night streak. Mirrored by the app for the widget.
        static let streak = "streak"
        /// "yyyy-MM-dd" of the most recent logged night, so the widget knows whether tonight is done.
        static let lastLoggedDay = "lastLoggedDay"
        /// Drinks logged for that night (0 = dry).
        static let lastLoggedDrinks = "lastLoggedDrinks"
        /// Money saved so far, in the user's currency units, for the widget subtitle.
        static let moneySaved = "moneySaved"
        /// Set by the widget / Siri intent; the app logs tonight as dry on next foreground.
        static let pendingDryNight = "pendingDryNight"
    }

    /// Day formatter shared by app and widget. Calendar-local, no time.
    static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
