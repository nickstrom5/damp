import Foundation

/// What the user told us during onboarding. Drives every personalized number in the app.
struct OnboardingAnswers: Codable, Equatable {
    var drinksPerWeek: Int = 10
    var pricePerDrink: Double = 8
    var reasons: Set<Reason> = []
    /// Dry nights per week the user committed to.
    var dryNightsGoal: Int = 4

    enum Reason: String, Codable, CaseIterable, Identifiable {
        case sleep, money, hangxiety, weight, health, challenge

        var id: String { rawValue }

        var label: String {
            switch self {
            case .sleep: return "Sleep better"
            case .money: return "Save money"
            case .hangxiety: return "Hangxiety"
            case .weight: return "Lose weight"
            case .health: return "Long-term health"
            case .challenge: return "A dry month"   // Sober October, Dry January; the long form truncated on an iPhone SE
            }
        }

        var symbol: String {
            switch self {
            case .sleep: return "moon.zzz.fill"
            case .money: return "dollarsign.circle.fill"
            case .hangxiety: return "waveform.path.ecg"
            case .weight: return "figure.run"
            case .health: return "heart.fill"
            case .challenge: return "flag.checkered"
            }
        }
    }

    // MARK: - Assumptions (documented in playbook/01-strategy.md, cite before submission)

    /// Average calories in one standard drink. Beer ~150, wine ~125, cocktail ~200. Kept round.
    static let caloriesPerDrink = 150
    /// A day of food, for turning calories into something people can picture.
    static let caloriesPerDayOfFood = 2000

    // MARK: - Reveal math

    var baselineDrinksPerDay: Double { Double(drinksPerWeek) / 7 }

    /// What a year of drinking costs at the stated rate.
    var yearlySpend: Int { Int((Double(drinksPerWeek) * 52 * pricePerDrink).rounded()) }

    var yearlyCalories: Int { drinksPerWeek * 52 * Self.caloriesPerDrink }

    /// Calories per year expressed as whole days of eating.
    var yearlyDaysOfFood: Int { yearlyCalories / Self.caloriesPerDayOfFood }

    /// What one dry night is worth, assuming drinks are spread evenly across the week.
    /// Conservative: most people drink on fewer nights than seven, so a real dry night saves more.
    var savedPerDryNight: Double { baselineDrinksPerDay * pricePerDrink }

    /// Money back per year if the user hits their weekly goal.
    var yearlySavingsAtGoal: Int { Int((Double(dryNightsGoal) * 52 * savedPerDryNight).rounded()) }

    var weeklySavingsAtGoal: Int { Int((Double(dryNightsGoal) * savedPerDryNight).rounded()) }
}
