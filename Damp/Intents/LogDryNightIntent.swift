import AppIntents
import Foundation

/// Lets the Home Screen widget, Siri, Shortcuts and the Action Button log tonight as dry.
/// Compiled into both the app and the widget extension.
struct LogDryNightIntent: AppIntent {
    static var title: LocalizedStringResource = "Log a dry night"
    static var description = IntentDescription("Marks tonight as a dry night in Damp.")
    static var openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppGroup.defaults.set(true, forKey: AppGroup.Key.pendingDryNight)
        return .result()
    }
}
