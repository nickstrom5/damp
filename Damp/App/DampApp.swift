import SwiftUI

@main
@MainActor
struct DampApp: App {
    @StateObject private var appState: AppState
    @StateObject private var store: StoreManager
    @StateObject private var reminders: ReminderManager

    init() {
        var sinks: [AnalyticsSink] = [ConsoleAnalytics()]
        if let postHog = PostHogAnalytics.start() { sinks.append(postHog) }
        Analytics.sink = CompositeAnalytics(sinks: sinks)

        let state = AppState()
        if ScreenshotMode.isActive { ScreenshotMode.seed(state) }
        let reminders = ReminderManager()
        reminders.onDryNight = { [weak state] in
            guard let state, state.hasCompletedOnboarding, state.todayLog == nil else { return }
            state.log(drinks: 0, source: "notification")
        }
        _appState = StateObject(wrappedValue: state)
        _store = StateObject(wrappedValue: StoreManager())
        _reminders = StateObject(wrappedValue: reminders)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(store)
                .environmentObject(reminders)
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
                .task {
                    Analytics.track(.appOpen)
                    appState.consumePendingIntent()
                    await reminders.refreshStatus()
                    await store.load()
                }
        }
    }
}

/// Routes between onboarding and the main app.
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            if let screen = ScreenshotMode.screen {
                ScreenshotRouter(screen: screen)
            } else if appState.hasCompletedOnboarding {
                HomeView()
                    .transition(.opacity)
            } else {
                OnboardingFlow()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appState.hasCompletedOnboarding)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { appState.consumePendingIntent() }
        }
    }
}

/// Renders exactly one screen for `-screenshot <name>` launches.
private struct ScreenshotRouter: View {
    @EnvironmentObject private var appState: AppState
    let screen: ScreenshotMode.Screen

    var body: some View {
        switch screen {
        case .hook:      OnboardingFlow(initialStep: .hook)
        case .drinks:    OnboardingFlow(initialStep: .drinks)
        case .price:     OnboardingFlow(initialStep: .price)
        case .reasons:   OnboardingFlow(initialStep: .reasons)
        case .reveal:    OnboardingFlow(initialStep: .reveal)
        case .goal:      OnboardingFlow(initialStep: .goal)
        case .first:     OnboardingFlow(initialStep: .first)
        case .result:    OnboardingFlow(initialStep: .result)
        case .paywall:   PaywallView(context: .onboarding, onFinished: {})
        case .home:      HomeView()
        case .log:       HomeView(initialSheet: .log)
        case .milestone: HomeView(initialSheet: .milestone(7))
        case .settings:  SettingsView()
        case .share:     HomeView(initialSheet: .milestone(30))
        }
    }
}
