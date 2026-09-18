import SwiftUI

/// Shown once per milestone streak. The number, what it's worth, and the card to post.
struct MilestoneView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let streak: Int
    @State private var shareImage: UIImage?

    private var worth: Double { Double(streak) * appState.answers.savedPerDryNight }
    private var cardTitle: String { "\(streak) dry night\(streak == 1 ? "" : "s")" }
    private var cardDetail: String { "\(Stats.money(worth)) kept" }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(headline)
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.textSecondary)
                        .padding(.top, 8)
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        CountUpText(target: streak)
                            .font(Theme.Font.display(88))
                            .foregroundStyle(Theme.accent)
                        Text(streak == 1 ? "dry night." : "dry nights\nin a row.")
                            .font(Theme.Font.title)
                            .foregroundStyle(Theme.textPrimary)
                    }
                    Text("That's about \(Stats.money(worth)) kept and \(Stats.calories(Int(Double(streak) * appState.answers.baselineDrinksPerDay * Double(OnboardingAnswers.caloriesPerDrink)))) calories skipped. And \(streak) morning\(streak == 1 ? "" : "s") you woke up clear.")
                        .font(Theme.Font.body)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)

                    ShareCardView(title: cardTitle, detail: cardDetail, streak: streak)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)

                    SecondaryButton(title: "Share the card") {
                        Analytics.track(.shareTapped, ["from": "milestone", "streak": streak])
                        shareImage = ShareCardView(title: cardTitle, detail: cardDetail, streak: streak).render()
                    }
                    .padding(.top, 12)
                    PrimaryButton(title: "Keep going") { dismiss() }
                        .padding(.top, 4)
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.top, 36)
                .padding(.bottom, 24)
            }
            ConfettiView().ignoresSafeArea()
        }
        .sheet(item: $shareImage) { image in
            ShareSheet(items: [image, "\(cardTitle) with Damp. \(cardDetail). usedamp.app"])
        }
    }

    private var headline: String {
        switch streak {
        case 1: return "First one down."
        case 3: return "Three's a pattern."
        case 7: return "A whole week."
        case 14: return "Two weeks. This is a habit now."
        case 30: return "A month. Most people never get here."
        case 60: return "Two months."
        case 100: return "Triple digits."
        case 365: return "A year."
        default: return "Milestone."
        }
    }
}
