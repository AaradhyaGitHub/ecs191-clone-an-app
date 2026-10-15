import CoreLocation

/// Filters and sorts landmarks for the search screen.
enum LandmarkSearch {
    struct Match: Identifiable {
        let landmark: Landmark
        /// Set when the query matched an alias but not the name, e.g. "MU".
        let matchedAlias: String?
        /// Meters from the user, if their location is known.
        let meters: Double?
        var id: String { landmark.id }
    }

    /// Case-insensitive partial match on name, then aliases. Empty query returns everything.
    /// Sorted nearest first when `from` is known, otherwise A–Z.
    static func matches(_ landmarks: [Landmark], query: String, from user: CLLocationCoordinate2D?) -> [Match] {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        let results: [Match] = landmarks.compactMap { landmark in
            let meters = zip(user, landmark.coordinate).map { Ranking.haversineMeters($0, $1) }
            if needle.isEmpty || landmark.name.lowercased().contains(needle) {
                return Match(landmark: landmark, matchedAlias: nil, meters: meters)
            }
            if let alias = landmark.aliases.first(where: { $0.lowercased().contains(needle) }) {
                return Match(landmark: landmark, matchedAlias: alias, meters: meters)
            }
            return nil
        }
        return results.sorted { a, b in
            if let ma = a.meters, let mb = b.meters { return ma < mb }
            return a.landmark.name < b.landmark.name
        }
    }

    /// Combines two optionals into one optional pair.
    private static func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
        guard let a, let b else { return nil }
        return (a, b)
    }
}
