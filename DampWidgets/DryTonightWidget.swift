import AppIntents
import SwiftUI
import WidgetKit

/// Small Home Screen widget: streak + a one-tap "Tonight's dry" button. The button runs the same
/// intent Siri and the Action Button use, which opens the app and logs the night.
struct DryTonightWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DryTonightWidget", provider: StreakProvider()) { entry in
            DryTonightWidgetView(entry: entry)
                .containerBackground(Color(red: 0.06, green: 0.07, blue: 0.10), for: .widget)
        }
        .configurationDisplayName("Dry tonight")
        .description("Your streak, and one tap to log tonight.")
        .supportedFamilies([.systemSmall])
    }
}

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let moneySaved: Double
    /// nil = tonight not logged; 0 = dry; n = drinks.
    let tonightDrinks: Int?
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 7, moneySaved: 80, tonightDrinks: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(current())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        // Refresh just after midnight so "tonight" resets, or in an hour, whichever is sooner.
        let cal = Calendar.current
        let midnight = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: Date())!).addingTimeInterval(60)
        let next = min(midnight, Date().addingTimeInterval(3600))
        completion(Timeline(entries: [current()], policy: .after(next)))
    }

    private func current() -> StreakEntry {
        let defaults = AppGroup.defaults
        let today = AppGroup.dayFormatter.string(from: Date())
        var tonight: Int?
        if defaults.string(forKey: AppGroup.Key.lastLoggedDay) == today {
            tonight = defaults.integer(forKey: AppGroup.Key.lastLoggedDrinks)
        }
        return StreakEntry(date: Date(),
                           streak: defaults.integer(forKey: AppGroup.Key.streak),
                           moneySaved: defaults.double(forKey: AppGroup.Key.moneySaved),
                           tonightDrinks: tonight)
    }
}

private struct DryTonightWidgetView: View {
    let entry: StreakEntry
    private let accent = Color(red: 0.49, green: 0.91, blue: 0.72)

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill").foregroundStyle(accent)
                Text("\(entry.streak)")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundStyle(.white)
                Text(entry.streak == 1 ? "night" : "nights")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
            }
            Text(entry.moneySaved.formatted(.currency(code: "USD").precision(.fractionLength(0))) + " kept")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            switch entry.tonightDrinks {
            case .some(0):
                Label("Tonight's dry", systemImage: "checkmark.circle.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(accent)
            case .some(let n):
                Label("Tonight: \(n)", systemImage: "wineglass.fill")
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
            case .none:
                Button(intent: LogDryNightIntent()) {
                    Text("Tonight's dry")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}
