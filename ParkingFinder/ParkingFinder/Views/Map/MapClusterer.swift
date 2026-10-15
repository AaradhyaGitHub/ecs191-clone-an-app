import MapKit

/// One thing drawn on the home map: either a single lot or a "donut" that
/// stands for several lots.
struct MapMarker: Identifiable {
    enum Kind {
        case cluster(Cluster)
        case lot(Lot)
    }

    struct Cluster {
        let lots: [Lot]
        let name: String?
        var count: Int { lots.count }
        var cCount: Int { lots.filter { $0.zones.contains("C") }.count }
        var lCount: Int { lots.filter { $0.zones.contains("L") }.count }
    }

    let id: String
    let coordinate: CLLocationCoordinate2D
    let kind: Kind
}

/// Groups lots into markers for a zoom level. The result only depends on the
/// level (not on where the map is panned), so it's computed once per level and
/// cached. Panning never re-clusters, which keeps the map smooth.
enum MapClusterer {
    /// - Parameter mapHeight: map height in points, used to turn "points on screen" into meters.
    static func markers(for lots: [Lot], level: ZoomLevel, mapHeight: Double) -> [MapMarker] {
        guard !lots.isEmpty, mapHeight > 0 else { return [] }

        // How many meters one screen point covers at this level (1° of latitude ≈ 111 km),
        // so the on-screen merge distance can be turned into meters.
        let metersPerPoint = level.span * 111_000 / mapHeight
        let mergeMeters = level.mergeDistance * metersPerPoint

        // Greedy grouping: each lot joins the first group whose first lot is close enough.
        var groups: [[Lot]] = []
        for lot in lots {
            if let index = groups.firstIndex(where: { Ranking.haversineMeters($0[0].coordinate, lot.coordinate) < mergeMeters }) {
                groups[index].append(lot)
            } else {
                groups.append([lot])
            }
        }
        groups = mergeOverlapping(groups, within: mergeMeters * 0.8)

        return groups.map { group in
            if group.count == 1, !level.showsAreasOnly {
                // Level 5 draws a different shape (a zone label), so it gets its own id.
                let prefix = level == .yourZone ? "zone" : "lot"
                return MapMarker(id: "\(prefix)-\(group[0].id)", coordinate: group[0].coordinate, kind: .lot(group[0]))
            }
            return MapMarker(
                id: "\(level.rawValue)-\(group[0].id)",
                coordinate: center(of: group),
                kind: .cluster(.init(lots: group, name: commonArea(of: group)))
            )
        }
    }

    /// Two groups can still end up with centers almost on top of each other
    /// (spec: markers must never overlap). Keep merging the first such pair
    /// until none are left. There are only a few dozen groups, so this is instant.
    private static func mergeOverlapping(_ groups: [[Lot]], within meters: Double) -> [[Lot]] {
        var groups = groups
        var merged = true
        while merged {
            merged = false
            search: for i in groups.indices {
                for j in groups.indices where j > i {
                    if Ranking.haversineMeters(center(of: groups[i]), center(of: groups[j])) < meters {
                        groups[i] += groups[j]
                        groups.remove(at: j)
                        merged = true
                        break search
                    }
                }
            }
        }
        return groups
    }

    private static func center(of lots: [Lot]) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: lots.map(\.coordinate.latitude).reduce(0, +) / Double(lots.count),
            longitude: lots.map(\.coordinate.longitude).reduce(0, +) / Double(lots.count)
        )
    }

    /// A label for the donut, only when most of its lots share an area name in the data.
    private static func commonArea(of lots: [Lot]) -> String? {
        let areas = lots.compactMap(\.area)
        guard let top = Dictionary(grouping: areas, by: { $0 }).max(by: { $0.value.count < $1.value.count }),
              top.value.count * 2 > lots.count else { return nil }
        return top.key
    }
}
