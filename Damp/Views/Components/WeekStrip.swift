import SwiftUI

/// Seven circles. Dry is filled, a drinking night shows the count, tonight pulses, the rest wait.
struct WeekStrip: View {
    let days: [WeekDay]
    let goal: Int
    let dryCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This week")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.textTertiary)
                Spacer()
                Text("\(dryCount) of \(goal) dry nights")
                    .font(Theme.Font.caption)
                    .foregroundStyle(dryCount >= goal ? Theme.accent : Theme.textSecondary)
            }
            HStack(spacing: 8) {
                ForEach(days) { day in
                    VStack(spacing: 6) {
                        DayDot(status: day.status)
                        Text(day.date, format: .dateTime.weekday(.narrow))
                            .font(Theme.Font.caption)
                            .foregroundStyle(Theme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
    }
}

struct DayDot: View {
    let status: DayStatus

    var body: some View {
        ZStack {
            switch status {
            case .dry:
                Circle().fill(Theme.accent)
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.black)
            case .drank(let n):
                Circle().fill(Theme.surfaceRaised)
                Text("\(n)")
                    .font(Theme.Font.mono(14))
                    .foregroundStyle(Theme.warning)
            case .missed:
                Circle().stroke(Theme.surfaceRaised, lineWidth: 2)
                Text("–")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.textTertiary)
            case .today:
                Circle().stroke(Theme.accent, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
            case .future:
                Circle().stroke(Theme.surfaceRaised, lineWidth: 2)
            }
        }
        .frame(width: 34, height: 34)
    }
}
