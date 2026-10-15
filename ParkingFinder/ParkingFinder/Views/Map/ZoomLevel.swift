import MapKit

/// The six map zoom levels from DESIGN_SPEC.md §4. The level is derived from
/// how many degrees of latitude the map shows (its `latitudeDelta`).
enum ZoomLevel: Int, CaseIterable, Comparable {
    case city, areas, clusters, lots, lotsAndZones, yourZone

    var name: String {
        switch self {
        case .city: "City"
        case .areas: "Campus areas"
        case .clusters: "Clusters"
        case .lots: "Lots"
        case .lotsAndZones: "Lots + zones"
        case .yourZone: "Your zone"
        }
    }

    init(latitudeDelta: Double) {
        switch latitudeDelta {
        case 0.06...: self = .city
        case 0.035..<0.06: self = .areas
        case 0.02..<0.035: self = .clusters
        case 0.012..<0.02: self = .lots
        case 0.006..<0.012: self = .lotsAndZones
        default: self = .yourZone
        }
    }

    /// The span the + / − buttons zoom to: roughly the middle of each band.
    var span: Double {
        switch self {
        case .city: 0.09
        case .areas: 0.045
        case .clusters: 0.027
        case .lots: 0.016
        case .lotsAndZones: 0.009
        case .yourZone: 0.0045
        }
    }

    /// How close (in screen points) two markers can get before they merge.
    /// Bigger at city scale so whole areas become one donut.
    var mergeDistance: Double {
        switch self {
        case .city: 150
        case .areas: 110
        case .clusters: 72
        case .lots: 46
        case .lotsAndZones: 60
        case .yourZone: 44
        }
    }

    /// Levels 0–2 never draw individual lots (spec "overlap rule").
    var showsAreasOnly: Bool { self <= .clusters }

    var next: ZoomLevel? { ZoomLevel(rawValue: rawValue + 1) }
    var previous: ZoomLevel? { ZoomLevel(rawValue: rawValue - 1) }

    static func < (a: ZoomLevel, b: ZoomLevel) -> Bool { a.rawValue < b.rawValue }
}
