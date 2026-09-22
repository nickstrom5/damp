import SwiftUI

/// Shown once per milestone streak. The number, what it's worth, and the card to post.
struct MilestoneView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    let streak: Int
    @State private var shareImage: UIImage?
    /// Measured so the 300pt card can shrink to sit fully above the pinned buttons on an iPhone SE.
    @State private var availableHeight: CGFloat = 900
    private var cardScale: CGFloat { availableHeight < 700 ? 0.72 : 1 }

    private var worth: Double { Double(streak) * appState.answers.savedPerDryNight }
    private var cardTitle: String { "\(streak) dry night\(streak == 1 ? "" : "s")" }
    private var cardDetail: String { "\(Stats.money(worth)) kept" }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
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
                            .scaleEffect(cardScale)
                            .frame(width: 300 * cardScale, height: 300 * cardScale)
                            .frame(maxWidth: .infinity)
                            .padding(.top, cardScale < 1 ? 8 : 24)
                    }
                    .padding(.horizontal, Theme.horizontalPadding)
                    .padding(.top, 36)
                    .padding(.bottom, 24)
                }
                .fadesUnderPinnedButton()
                // Pinned, so the way out is on screen even when the card doesn't fit (iPhone SE).
                VStack(spacing: 4) {
                    SecondaryButton(title: "Share the card") {
                        Analytics.track(.shareTapped, ["from": "milestone", "streak": streak])
                        shareImage = ShareCardView(title: cardTitle, detail: cardDetail, streak: streak).render()
                    }
                    PrimaryButton(title: "Keep going") { dismiss() }
                }
                .padding(.horizontal, Theme.horizontalPadding)
                .padding(.bottom, 16)
            }
            .background(GeometryReader { geo in
                Color.clear
                    .onAppear { availableHeight = geo.size.height }
                    .onChange(of: geo.size.height) { _, h in availableHeight = h }
            })
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
