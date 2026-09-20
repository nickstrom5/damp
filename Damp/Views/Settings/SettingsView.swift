import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: StoreManager
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var reminders: ReminderManager
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    private let goals = [3, 4, 5, 7]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DatePicker("Check-in time", selection: reminderBinding, displayedComponents: .hourAndMinute)
                    if !reminders.isAuthorized {
                        Button("Turn on notifications") {
                            Task {
                                let granted = await reminders.requestAuthorization()
                                if granted { reminders.schedule(minutesAfterMidnight: appState.reminderMinutes) }
                                else if let url = URL(string: UIApplication.openSettingsURLString) { await UIApplication.shared.open(url) }
                            }
                        }
                    }
                } header: {
                    Text("Nightly check-in")
                } footer: {
                    Text(reminders.isAuthorized
                         ? "One notification at \(ReminderManager.label(forMinutes: appState.reminderMinutes)). Tap Dry or Drank right from it."
                         : "Notifications are off, so the check-in can't reach you. The widget and Siri still work.")
                }

                Section("Your numbers") {
                    Stepper("Drinks a week: \(appState.answers.drinksPerWeek)", value: $appState.answers.drinksPerWeek, in: 0...60)
                    Stepper("Per drink: \(Stats.money(appState.answers.pricePerDrink))", value: $appState.answers.pricePerDrink, in: 1...50, step: 1)
                    Picker("Dry nights a week", selection: $appState.answers.dryNightsGoal) {
                        ForEach(goals, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("So far") {
                    LabeledContent("Current streak", value: "\(appState.stats.streak) nights")
                    LabeledContent("Longest streak", value: "\(appState.stats.longestStreak) nights")
                    LabeledContent("Dry nights", value: "\(appState.stats.dryNights) of \(appState.stats.loggedNights) logged")
                    LabeledContent("Kept", value: appState.stats.moneySavedFormatted)
                    LabeledContent("Calories skipped", value: Stats.calories(appState.stats.caloriesSkipped))
                }

                Section("Plan") {
                    if store.isPro {
                        LabeledContent("Damp Pro", value: "Active")
                        Button("Manage subscription") {
                            if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                UIApplication.shared.open(url)
                            }
                        }
                    } else {
                        Button("Upgrade to Damp Pro") { showPaywall = true }
                    }
                    Button("Restore purchases") { Task { await store.restore() } }
                }

                HelpSection()

                Section {
                    Link("Privacy policy", destination: Config.privacyURL)
                    Link("Terms", destination: Config.termsURL)
                } footer: {
                    Text("Damp \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "") · Everything stays on your phone. Damp is a habit tracker, not medical advice. If drinking feels out of control, talk to a doctor or call SAMHSA's helpline: 1-800-662-4357.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(context: .home, onFinished: { showPaywall = false })
            }
            .onChange(of: appState.reminderMinutes) { _, minutes in
                Analytics.track(.reminderTimeChanged, ["minutes": minutes])
                if reminders.isAuthorized { reminders.schedule(minutesAfterMidnight: minutes) }
            }
        }
    }

    private var reminderBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = appState.reminderMinutes / 60
                components.minute = appState.reminderMinutes % 60
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                appState.reminderMinutes = (c.hour ?? 21) * 60 + (c.minute ?? 0)
            }
        )
    }
}
