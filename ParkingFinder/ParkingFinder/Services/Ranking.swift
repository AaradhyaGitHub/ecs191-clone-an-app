import CoreLocation

/// Pure functions: distance, grouping spots into lots, and picking the closest lots.
/// No UI and no state, so they are easy to unit test (see RankingTests).
enum Ranking {
    /// Great-circle distance in meters between two coordinates (Haversine formula).
    static func haversineMeters(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6_371_000.0
        let lat1 = a.latitude * .pi / 180
        let lat2 = b.latitude * .pi / 180
        let dLat = (b.latitude - a.latitude) * .pi / 180
        let dLon = (b.longitude - a.longitude) * .pi / 180
        let h = sin(dLat / 2) * sin(dLat / 2)
            + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * earthRadius * asin(min(1, sqrt(h)))
    }

    /// The data has one point per AMP sign, so one lot can have several points.
    /// Each spot joins the first group whose *first* spot is within `meters`;
    /// otherwise it starts a new group. Comparing to the first spot (not any spot)
    /// stops long rows of street spots from chaining into one giant "lot".
    static func groupIntoLots(_ spots: [ParkingSpot], within meters: Double) -> [Lot] {
        var groups: [[ParkingSpot]] = []
        for spot in spots {
            let here = coordinate(of: spot)
            if let index = groups.firstIndex(where: { haversineMeters(coordinate(of: $0[0]), here) <= meters }) {
                groups[index].append(spot)
            } else {
                groups.append([spot])
            }
        }
        return groups.map(makeLot)
    }

    /// The `count` closest lots to `origin`, closest first.
    static func topLots(_ lots: [Lot], near origin: CLLocationCoordinate2D, count: Int) -> [Lot] {
        let sorted = lots
            .map { (lot: $0, meters: haversineMeters(origin, $0.coordinate)) }
            .sorted { $0.meters < $1.meters }
        return sorted.prefix(count).map(\.lot)
    }

    // MARK: - Helpers

    private static func coordinate(of spot: ParkingSpot) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: spot.coords.lat, longitude: spot.coords.lon)
    }

    private static func makeLot(from spots: [ParkingSpot]) -> Lot {
        let lat = spots.map(\.coords.lat).reduce(0, +) / Double(spots.count)
        let lon = spots.map(\.coords.lon).reduce(0, +) / Double(spots.count)
        let zones = Set(spots.flatMap(\.permits)).sorted()
        // Name: prefer a numbered lot ("Lot 47 …"), then a spot students can use
        // (so a lot with A and C spots isn't called "A Zone"), then any zoned spot.
        let named = spots.first { $0.lot != nil }
            ?? spots.first { $0.permits.contains(where: Config.studentZones.contains) }
            ?? spots.first { !$0.permits.isEmpty }
            ?? spots[0]
        return Lot(
            id: spots[0].id,
            name: named.name,
            zones: zones,
            coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            area: spots.compactMap(\.area).first
        )
    }
}
