import CoreLocation

/// A campus building from landmarks.json. Coordinates may be null until the
/// developer fills them in; those landmarks are skipped.
struct Landmark: Decodable, Identifiable, Equatable {
    let id: String
    let name: String
    let aliases: [String]
    /// Optional second line in search, e.g. "Peter J. Shields Library".
    let subtitle: String?
    /// Short name for the walk line, e.g. "Olson" in "… walk (320 m) to Olson".
    let shortName: String?
    let lat: Double?
    let lon: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat, let lon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    var displayShortName: String { shortName ?? name }
}
