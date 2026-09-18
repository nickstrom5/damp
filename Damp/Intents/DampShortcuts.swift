import AppIntents

/// Exposes the intent to Siri, Spotlight and the Shortcuts app. App target only.
struct DampShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogDryNightIntent(),
            phrases: [
                "Log a dry night in \(.applicationName)",
                "Tonight is dry in \(.applicationName)",
                "I'm not drinking tonight, \(.applicationName)"
            ],
            shortTitle: "Dry tonight",
            systemImageName: "drop.fill"
        )
    }
}
