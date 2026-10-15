import CoreLocation

/// One physical parking lot, made by grouping nearby `ParkingSpot`s
/// (see `Ranking.groupIntoLots`). The 3 results are always 3 different lots.
struct Lot: Identifiable, Equatable {
    let id: String
    let name: String
    /// Every zone letter accepted anywhere in the lot, sorted, e.g. ["C", "L"].
    let zones: [String]
    let coordinate: CLLocationCoordinate2D
    /// Street or neighborhood from the data, when it has one (e.g. "Horizon St").
    let area: String?

    /// True when the lot accepts at least one student zone.
    func isStudentEligible(_ studentZones: Set<String>) -> Bool {
        if studentZones.isEmpty { return true }
        return zones.contains { studentZones.contains($0) }
    }

    static func == (a: Lot, b: Lot) -> Bool { a.id == b.id }
}
