import SwiftUI

/// One button. Everything else on this screen exists to make you press it again tomorrow.
struct HomeView: View {
    enum Sheet: Identifiable, Equatable {
        case settings
        case paywall
        /// Log drinks for a day (today or yesterday).
        case log
        case logYesterday
        case milestone(Int)

        var id: String {
            switch self {
            case .settings: return "settings"
            case .paywall: return "paywall"
            case .log: return "log"
            case .logYesterday: return "logYesterday"
            case .milestone(let n): return "milestone-\(n)"
            }
        }
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var reminders: ReminderManager

    @State private var sheet: Sheet?
    @State private var celebrate = false

    init(initialSheet: Sheet? = nil) {
        _sheet = State(initialValue: initialSheet)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        streakHeader
                        WeekStrip(days: appState.thisWeek, goal: appState.answers.dryNightsGoal, dryCount: appState.dryNightsThisWeek)
                        if appState.yesterdayMissed { missedBanner }
                        tonight
                        savings
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                if celebrate { ConfettiView().ignoresSafeArea() }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "drop.fill").foregroundStyle(Theme.accent)
                        Text("Damp")
                            .font(Theme.Font.headline)
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .padding(.horizontal, 6)
                    .fixedSize()   // iOS 26 glass capsule otherwise clips the text
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { sheet = .settings } label: {
                        Image(systemName: "gearshape.fill").foregroundStyle(Theme.textSecondary)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .settings:
                SettingsView()
            case .paywall:
                PaywallView(context: .home, onFinished: { self.sheet = nil })
            case .log:
                LogDrinksSheet(day: Date(), existing: appState.todayLog) { drinks in
                    appState.log(drinks: drinks, source: "home")
                }
                .presentationDetents([.height(420)])
            case .logYesterday:
                LogDrinksSheet(day: appState.yesterday, existing: appState.yesterdayLog) { drinks in
                    appState.log(day: appState.yesterday, drinks: drinks, source: "home_yesterday")
                }
                .presentationDetents([.height(420)])
            case .milestone(let streak):
                MilestoneView(streak: streak)
            }
        }
        .onChange(of: appState.pendingMilestone) { _, milestone in
            guard let milestone else { return }
            appState.pendingMilestone = nil
            sheet = .milestone(milestone)
        }
        .onAppear {
            appState.consumePendingIntent()
            reminders.onDrank = { sheet = .log }
        }
    }

    // MARK: - Sections

    private var streakHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            if appState.stats.streak > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(appState.stats.streak)")
                        .font(Theme.Font.display(64))
                        .foregroundStyle(Theme.accent)
                        .contentTransition(.numericText())
                    Text(appState.stats.streak == 1 ? "dry night in a row" : "dry nights in a row")
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text(appState.todayLog == nil ? "Start a streak tonight." : "Tomorrow's a fresh start.")
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.textPrimary)
            }
            Text(subline)
                .font(Theme.Font.body)
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var subline: String {
        let s = appState.stats
        if s.loggedNights == 0 { return "Log tonight and the count begins." }
        return "\(s.moneySavedFormatted) kept · \(Stats.calories(s.caloriesSkipped)) cal skipped · \(s.dryNights) dry night\(s.dryNights == 1 ? "" : "s")"
    }

    private var missedBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Forgot last night?")
                    .font(Theme.Font.headline)
                    .foregroundStyle(Theme.textPrimary)
                Text("Unlogged nights don't count either way.")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.textTertiary)
            }
            Spacer()
            Button("Dry") { gated { appState.log(day: appState.yesterday, drinks: 0, source: "home_yesterday") } }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .foregroundStyle(.black)
            Button("Drinks") { gated { sheet = .logYesterday } }
                .buttonStyle(.bordered)
                .tint(Theme.textSecondary)
        }
        .font(Theme.Font.caption)
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var tonight: some View {
        VStack(spacing: 14) {
            if let today = appState.todayLog {
                VStack(spacing: 6) {
                    Image(systemName: today.isDry ? "checkmark.circle.fill" : "wineglass.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(today.isDry ? Theme.accent : Theme.warning)
                    Text(today.isDry ? "Tonight is dry." : "Tonight: \(today.drinks) drink\(today.drinks == 1 ? "" : "s").")
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.textPrimary)
                    Text(today.isDry ? "See you at the check-in tomorrow." : "Logged. Tomorrow's a fresh start.")
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.textTertiary)
                }
                .padding(.vertical, 28)
                Button("Change tonight") { gated { sheet = .log } }
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                DryNightButton(title: "Tonight's dry", subtitle: "Worth \(Stats.money(appState.answers.savedPerDryNight))") {
                    gated { logDry() }
                }
                .padding(.top, 8)
                Button("I had a drink") { gated { sheet = .log } }
                    .font(Theme.Font.headline)
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.vertical, 6)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var savings: some View {
        let s = appState.stats
        return HStack(spacing: 10) {
            StatTile(value: s.moneySavedFormatted, label: "kept")
            StatTile(value: Stats.calories(s.caloriesSkipped), label: "cal skipped")
            StatTile(value: "\(s.dryNights)", label: "dry nights")
        }
    }

    // MARK: - Actions

    /// The core action is behind the paywall. Nothing else is.
    private func gated(_ action: () -> Void) {
        guard store.isPro || ScreenshotMode.isActive else {
            Analytics.track(.paywallShown, ["from": "home"])
            sheet = .paywall
            return
        }
        action()
    }

    private func logDry() {
        appState.log(drinks: 0, source: "home")
        celebrate = true
        Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            celebrate = false
        }
    }
}

struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Font.mono(22))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
