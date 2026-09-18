import SwiftUI

/// "How many?" A stepper, five quick chips, one button. Logging a drinking night should feel
/// as easy as logging a dry one, or people stop logging.
struct LogDrinksSheet: View {
    let day: Date
    let existing: DayLog?
    let onLog: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var count: Int = 2

    private var isToday: Bool { Calendar.current.isDateInToday(day) }

    var body: some View {
        VStack(spacing: 20) {
            Text(isToday ? "How many tonight?" : "How many last night?")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.textPrimary)
                .padding(.top, 28)

            HStack(spacing: 28) {
                StepButton(symbol: "minus") { count = max(1, count - 1) }
                Text("\(count)")
                    .font(Theme.Font.display(72))
                    .foregroundStyle(Theme.warning)
                    .frame(minWidth: 90)
                    .contentTransition(.numericText())
                StepButton(symbol: "plus") { count = min(30, count + 1) }
            }

            HStack(spacing: 8) {
                ForEach([1, 2, 3, 4, 6], id: \.self) { n in
                    Chip(label: n == 6 ? "6+" : "\(n)", selected: count == n) { count = n }
                }
            }
            .padding(.horizontal, Theme.horizontalPadding)

            VStack(spacing: 8) {
                PrimaryButton(title: "Log \(count) drink\(count == 1 ? "" : "s")") {
                    onLog(count)
                    dismiss()
                }
                TertiaryButton(title: isToday ? "Actually, tonight's dry" : "Actually, it was dry") {
                    onLog(0)
                    dismiss()
                }
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Theme.background)
        .onAppear {
            if let existing, existing.drinks > 0 { count = existing.drinks }
        }
        .animation(.easeInOut(duration: 0.15), value: count)
    }
}

private struct StepButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.textPrimary)
                .frame(width: 56, height: 56)
                .background(Theme.surfaceRaised)
                .clipShape(Circle())
        }
        .buttonStyle(PressScaleStyle())
    }
}
