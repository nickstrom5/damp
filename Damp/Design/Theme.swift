import SwiftUI

/// One place for the look. Dark navy, mint accent, rounded type. Morning-after clarity, not
/// nightlife neon and not a clinic.
enum Theme {
    static let background = Color(red: 0.06, green: 0.07, blue: 0.10)
    static let surface = Color(red: 0.11, green: 0.13, blue: 0.17)
    static let surfaceRaised = Color(red: 0.16, green: 0.19, blue: 0.24)
    static let accent = Color(red: 0.49, green: 0.91, blue: 0.72)   // mint
    static let accentSoft = accent.opacity(0.18)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.38)
    static let danger = Color(red: 0.98, green: 0.45, blue: 0.40)
    static let warning = Color(red: 0.98, green: 0.78, blue: 0.38)
    static let success = accent

    static let cornerRadius: CGFloat = 20
    static let horizontalPadding: CGFloat = 24

    enum Font {
        static func display(_ size: CGFloat = 40) -> SwiftUI.Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        static let title = SwiftUI.Font.system(size: 28, weight: .bold, design: .rounded)
        static let headline = SwiftUI.Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = SwiftUI.Font.system(size: 17, weight: .regular, design: .rounded)
        static let caption = SwiftUI.Font.system(size: 13, weight: .medium, design: .rounded)
        static func mono(_ size: CGFloat) -> SwiftUI.Font {
            .system(size: size, weight: .semibold, design: .rounded).monospacedDigit()
        }
    }
}
