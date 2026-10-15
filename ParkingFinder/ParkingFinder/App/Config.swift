import Foundation

/// Every tunable value lives here so there is one place to change it.
enum Config {
    // TODO(developer): confirm against the TAPS daily rates page.
    // The design hand-off uses C (commuter) and L (resident). If this set is
    // empty, the app shows every lot and logs a warning.
    static let studentZones: Set<String> = ["C", "L"]

    /// Spots closer than this to a lot's first spot count as the same physical lot.
    static let sameLotMeters: Double = 50

    /// Farther than this from campus shows "You're not near UC Davis".
    static let farAwayMeters: Double = 15_000

    /// Walking speed used for "About N min walk".
    static let walkMetersPerMinute: Double = 80

    /// Drive times are for leaving 10 minutes from now.
    static let departureDelay: TimeInterval = 10 * 60

    /// The user counts as "in" a lot (zoom level 5 card) within this distance.
    static let insideLotMeters: Double = 60

    /// How many lots the results sheet shows.
    static let resultCount = 3
}
