import Foundation

/// The top level of parking_spots.json: `{ "meta": {...}, "spots": [...] }`.
struct ParkingSpotFile: Decodable {
    struct Meta: Decodable {
        let schemaVersion: Int
        let dataset: String
        let updated: String
        let coordinates: String
    }

    let meta: Meta
    let spots: [ParkingSpot]
}

/// One point from the AMP Park map. Matches parking_spots.json exactly.
/// Several spots can belong to the same physical lot (see `Lot`).
struct ParkingSpot: Decodable, Identifiable {
    struct Coords: Decodable {
        let lat: Double
        let lon: Double
    }

    struct Cluster: Decodable {
        let id: Int
        let tight: Bool
    }

    let id: String
    let name: String
    let coords: Coords
    let region: String?
    let area: String?
    /// Zone letters this spot accepts, e.g. ["C"]. Empty for hourly / motorcycle spots.
    let permits: [String]
    let tags: [String]
    /// Lot number when the AMP name includes one, e.g. 47 for "Lot 47 Hourly Parking".
    let lot: Int?
    let cluster: Cluster?
    let flags: [String]
    let notes: String?
}
