import UIKit

/// Centralized haptic feedback for the entire app.
///
/// WHY a dedicated manager?
///   - One place to tune intensity and patterns
///   - Easy to add a global "haptics off" toggle later
///   - Keeps UIKit imports out of SwiftUI views
///
/// HAPTIC TYPES on iPhone:
///   Impact   → physical tap feel (light/medium/heavy/soft/rigid)
///   Notification → success ✓, warning ⚠, error ✗
///   Selection → subtle click when scrubbing through options
enum HapticManager {

    // MARK: - Impact

    /// Light tap — navigation, selections, toggles
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium tap — button presses, confirmations
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Heavy tap — destructive actions, major game events
    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    /// Soft tap — subtle background events
    static func soft() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    /// Rigid tap — crisp, defined moments (score, copy confirmation)
    static func rigid() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    // MARK: - Notification

    /// Success — task complete, crew created, RSVP confirmed
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Warning — timer low, about to expire
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Error — invalid input, failed action
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    // MARK: - Selection

    /// Selection tick — picker changes, tab switches, round changes
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    // MARK: - Custom patterns

    /// Double-tap pattern — "got it!" moment in games
    static func doubleTap() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            generator.impactOccurred(intensity: 0.6)
        }
    }

    /// Countdown tick — used for final 5 seconds of timer
    static func tick() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.4)
    }
}
