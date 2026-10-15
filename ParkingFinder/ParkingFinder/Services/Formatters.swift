import Foundation

/// Text formatting shared by the cards and search rows.
enum Formatters {
    /// "1.3 mi"
    static func miles(_ meters: Double) -> String {
        String(format: "%.1f mi", meters / 1609.344)
    }

    /// "About 4 min walk (320 m) to Olson". Meters are rounded to the nearest 10.
    static func walkLine(meters: Double, to place: String) -> String {
        let minutes = max(1, Int((meters / Config.walkMetersPerMinute).rounded()))
        let roundedMeters = Int((meters / 10).rounded()) * 10
        return "About \(minutes) min walk (\(roundedMeters) m) to \(place)"
    }

    /// Whole minutes, never less than 1.
    static func minutes(_ seconds: TimeInterval) -> Int {
        max(1, Int((seconds / 60).rounded()))
    }
}
