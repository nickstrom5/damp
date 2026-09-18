import SwiftUI

// MARK: - 1. Hook

struct HookScreen: View {
    let onNext: () -> Void
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text("Skipping one drink a night gives you back")
                .font(Theme.Font.headline)
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text("$2,900")
                .font(Theme.Font.display(88))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)   // fits on a 375pt-wide SE without wrapping
                .padding(.vertical, -6)
            Text("a year. And every morning after.")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            PrimaryButton(title: "Show me my number", action: onNext)
            Text("Damp helps you drink less. Not never. One tap a night.")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.textTertiary)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, Theme.horizontalPadding)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear { withAnimation(.easeOut(duration: 0.6)) { appeared = true } }
    }
}

// MARK: - 2. Drinks per week

struct DrinksScreen: View {
    @EnvironmentObject private var appState: AppState
    let onNext: () -> Void

    var body: some View {
        OnboardingScreen(
            title: "Honestly, how many drinks a week?",
            subtitle: "A drink is a beer, a glass of wine or one cocktail. Most people guess low.",
            onCTA: onNext
        ) {
            VStack(spacing: 24) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(appState.answers.drinksPerWeek)")
                        .font(Theme.Font.display(72))
                        .foregroundStyle(Theme.accent)
                        .contentTransition(.numericText())
                    Text(appState.answers.drinksPerWeek == 1 ? "drink" : "drinks")
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                Slider(value: Binding(
                    get: { Double(appState.answers.drinksPerWeek) },
                    set: { appState.answers.drinksPerWeek = Int($0.rounded()) }
                ), in: 0...40, step: 1)
                .tint(Theme.accent)
                HStack {
                    Text("0").font(Theme.Font.caption).foregroundStyle(Theme.textTertiary)
                    Spacer()
                    Text("40+").font(Theme.Font.caption).foregroundStyle(Theme.textTertiary)
                }
                Text(comparison)
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }

    private var comparison: String {
        switch appState.answers.drinksPerWeek {
        case 0...3: return "That's light. Damp keeps it that way, and keeps the receipts."
        case 4...7: return "About the US average. Most people in this range don't feel it until they stop."
        case 8...14: return "One or two most nights. That's where sleep, money and mornings start to go."
        default: return "That's a lot of nights. Cutting even two a week changes the year."
        }
    }
}

// MARK: - 3. Price per drink

struct PriceScreen: View {
    @EnvironmentObject private var appState: AppState
    let onNext: () -> Void

    private let presets: [(label: String, detail: String, price: Double)] = [
        ("$3", "At home", 3), ("$8", "Mix of both", 8), ("$14", "Bars", 14)
    ]

    var body: some View {
        OnboardingScreen(
            title: "What does a drink usually cost you?",
            subtitle: "Rough is fine. This is how Damp counts what you keep.",
            onCTA: onNext
        ) {
            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    ForEach(presets, id: \.price) { preset in
                        Chip(label: preset.label, detail: preset.detail,
                             selected: appState.answers.pricePerDrink == preset.price) {
                            appState.answers.pricePerDrink = preset.price
                        }
                    }
                }
                VStack(spacing: 8) {
                    Text(Stats.money(appState.answers.pricePerDrink) + " a drink")
                        .font(Theme.Font.display(40))
                        .foregroundStyle(Theme.accent)
                        .contentTransition(.numericText())
                    Slider(value: $appState.answers.pricePerDrink, in: 1...30, step: 1)
                        .tint(Theme.accent)
                }
                .padding(.top, 8)
                Text("That's about **\(Stats.money(Double(appState.answers.yearlySpend)))** a year at \(appState.answers.drinksPerWeek) drinks a week.")
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

// MARK: - 4. Reasons

struct ReasonsScreen: View {
    @EnvironmentObject private var appState: AppState
    let onNext: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        OnboardingScreen(
            title: "Why drink less?",
            subtitle: "Pick everything that's true. Nobody's judging; the app doesn't even have an account.",
            ctaEnabled: !appState.answers.reasons.isEmpty,
            onCTA: onNext
        ) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(OnboardingAnswers.Reason.allCases) { reason in
                    Chip(label: reason.label, symbol: reason.symbol,
                         selected: appState.answers.reasons.contains(reason)) {
                        if appState.answers.reasons.contains(reason) {
                            appState.answers.reasons.remove(reason)
                        } else {
                            appState.answers.reasons.insert(reason)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 5. Reveal

struct RevealScreen: View {
    @EnvironmentObject private var appState: AppState
    let onNext: () -> Void
    @State private var showSecond = false
    @State private var showThird = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("At \(appState.answers.drinksPerWeek) drinks a week you spend")
                            .font(Theme.Font.headline)
                            .foregroundStyle(Theme.textSecondary)
                        CountUpText(target: appState.answers.yearlySpend, prefix: "$")
                            .font(Theme.Font.display(72))
                            .foregroundStyle(Theme.danger)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text("a year on alcohol.")
                            .font(Theme.Font.title)
                            .foregroundStyle(Theme.textPrimary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("In calories, that's")
                            .font(Theme.Font.headline)
                            .foregroundStyle(Theme.textSecondary)
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            CountUpText(target: appState.answers.yearlyDaysOfFood, delay: 0.9)
                                .font(Theme.Font.display(56))
                                .foregroundStyle(Theme.warning)
                            Text("full days of food.")
                                .font(Theme.Font.title)
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                    .opacity(showSecond ? 1 : 0)
                    .offset(y: showSecond ? 0 : 10)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(appState.answers.dryNightsGoal) dry nights a week gives you")
                            .font(Theme.Font.headline)
                            .foregroundStyle(Theme.textSecondary)
                        CountUpText(target: appState.answers.yearlySavingsAtGoal, prefix: "$", delay: 1.8)
                            .font(Theme.Font.display(72))
                            .foregroundStyle(Theme.accent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text("of it back. Every year. Plus the mornings.")
                            .font(Theme.Font.title)
                            .foregroundStyle(Theme.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .opacity(showThird ? 1 : 0)
                    .offset(y: showThird ? 0 : 10)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, 36)
                .padding(.bottom, 24)
            }
            PrimaryButton(title: "I want that back", action: onNext)
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 16)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.9)) { showSecond = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.8)) { showThird = true }
        }
    }
}

// MARK: - 6. Goal + check-in time

struct GoalScreen: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var reminders: ReminderManager
    let onNext: () -> Void
    @State private var requesting = false

    private let goals = [3, 4, 5, 7]

    var body: some View {
        OnboardingScreen(
            title: "How many dry nights a week?",
            subtitle: "Start where you'll actually win. You can change it any time.",
            cta: "Set my check-in",
            ctaLoading: requesting,
            onCTA: setReminder
        ) {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 8) {
                    ForEach(goals, id: \.self) { goal in
                        Chip(label: "\(goal)", detail: goal == 7 ? "fully dry" : "nights",
                             selected: appState.answers.dryNightsGoal == goal) {
                            appState.answers.dryNightsGoal = goal
                        }
                    }
                }
                Text("That's about **\(Stats.money(Double(appState.answers.yearlySavingsAtGoal)))** a year back, and \(appState.answers.dryNightsGoal * 52) clear mornings.")
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Your nightly check-in")
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text("One notification a night. Tap Dry or Drank right from it. That's the whole habit.")
                        .font(Theme.Font.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    DatePicker("Check-in time", selection: reminderBinding, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.textPrimary)
                        .tint(Theme.accent)
                }
                .padding(16)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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

    private func setReminder() {
        requesting = true
        Task {
            let granted = await reminders.requestAuthorization()
            if granted { reminders.schedule(minutesAfterMidnight: appState.reminderMinutes) }
            requesting = false
            onNext()
        }
    }
}

// MARK: - 7. First night (the taste)

struct FirstNightScreen: View {
    @EnvironmentObject private var appState: AppState
    let onNext: () -> Void
    @State private var logged = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Make tonight dry night #1?")
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.textPrimary)
                    Text("You're already here. One tap and the streak, the savings and the first card all start now.")
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, 36)

                Spacer()

                DryNightButton(title: logged ? "Dry ✓" : "Tonight's dry", subtitle: logged ? "Night 1" : "Tap to start", done: logged, action: logTonight)
                    .frame(maxWidth: .infinity)

                Text("Worth about \(Stats.money(appState.answers.savedPerDryNight)) by morning.")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 18)

                Spacer()

                TertiaryButton(title: "I'm drinking tonight. Start tomorrow.") {
                    Analytics.track(.firstNightSkipped)
                    onNext()
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 16)
                .opacity(logged ? 0 : 1)
            }
            if logged { ConfettiView().ignoresSafeArea() }
        }
        .onAppear {
            // Re-entry after a kill mid-onboarding: tonight is already logged, don't ask twice.
            if appState.todayLog != nil { onNext() }
        }
    }

    private func logTonight() {
        guard !logged else { return }
        appState.log(drinks: 0, source: "onboarding")
        Analytics.track(.firstNightLogged)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { logged = true }
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            onNext()
        }
    }
}

/// The one button. Big, round, mint. Same on the home screen.
struct DryNightButton: View {
    let title: String
    var subtitle: String? = nil
    var done: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: done ? "checkmark" : "drop.fill")
                    .font(.system(size: 44, weight: .semibold))
                Text(title)
                    .font(Theme.Font.display(28))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle {
                    Text(subtitle)
                        .font(Theme.Font.caption)
                        .opacity(0.7)
                }
            }
            .foregroundStyle(.black)
            .frame(width: 220, height: 220)
            .background(Theme.accent)
            .clipShape(Circle())
            .shadow(color: Theme.accent.opacity(0.35), radius: 30, y: 10)
        }
        .buttonStyle(PressScaleStyle())
        .disabled(done)
    }
}

// MARK: - 8. First result

struct FirstResultScreen: View {
    @EnvironmentObject private var appState: AppState
    let onNext: () -> Void
    @State private var shareImage: UIImage?

    private var loggedDry: Bool { appState.todayLog?.isDry == true }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(loggedDry ? "Dry night 1." : "Tomorrow is dry night 1.")
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.textPrimary)
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        CountUpText(target: Int(appState.answers.savedPerDryNight.rounded()), prefix: "$")
                            .font(Theme.Font.display(72))
                            .foregroundStyle(Theme.accent)
                        Text(loggedDry ? "kept by morning." : "waiting for you.")
                            .font(Theme.Font.title)
                            .foregroundStyle(Theme.textPrimary)
                    }
                    Text("At \(appState.answers.dryNightsGoal) nights a week that's \(Stats.money(Double(appState.answers.yearlySavingsAtGoal))) a year. Damp counts every night, and gives you a card at every milestone.")
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)

                    if loggedDry {
                        ShareCardView(title: "Dry night 1", detail: "\(Stats.money(appState.answers.savedPerDryNight)) kept", streak: 1)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                        SecondaryButton(title: "Share it") {
                            Analytics.track(.shareTapped, ["from": "onboarding"])
                            shareImage = ShareCardView(title: "Dry night 1", detail: "\(Stats.money(appState.answers.savedPerDryNight)) kept", streak: 1).render()
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, 36)
                .padding(.bottom, 24)
            }
            PrimaryButton(title: "Keep it going", action: onNext)
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 16)
        }
        .sheet(item: $shareImage) { image in
            ShareSheet(items: [image, "Dry night 1. Drinking less with Damp. usedamp.app"])
        }
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
}
