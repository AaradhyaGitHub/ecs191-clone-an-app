import CoreLocation
import MapKit

/// Loads parking_spots.json and landmarks.json from the app bundle once at launch.
@MainActor
@Observable
final class DataStore {
    private(set) var lots: [Lot] = []
    /// Lots a student can park in (`Config.studentZones`). Used for ranking and markers.
    private(set) var studentLots: [Lot] = []
    /// Everything else (A, F, hourly, motorcycle…). Drawn as small grey dots.
    private(set) var otherLots: [Lot] = []
    /// Landmarks that have coordinates. Ones still set to null are skipped.
    private(set) var landmarks: [Landmark] = []
    private(set) var loadError: String?

    /// The middle of all lots. Used for the "far from campus" check, so no
    /// campus coordinate has to be typed in by hand.
    private(set) var campusCenter = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    /// A region that fits every lot. The map starts here before the user's location is known.
    private(set) var campusRegion = MKCoordinateRegion()

    init() {
        loadLots()
        loadLandmarks()
    }

    private func loadLots() {
        do {
            let file: ParkingSpotFile = try Self.decode("parking_spots")
            lots = Ranking.groupIntoLots(file.spots, within: Config.sameLotMeters)
            if Config.studentZones.isEmpty {
                print("⚠️ Config.studentZones is empty, so every lot is shown as student parking.")
            }
            studentLots = lots.filter { $0.isStudentEligible(Config.studentZones) }
            otherLots = lots.filter { !$0.isStudentEligible(Config.studentZones) }
            computeCampusBounds()
            #if DEBUG
            print("Loaded \(file.spots.count) spots → \(lots.count) lots, \(studentLots.count) student lots (data updated \(file.meta.updated)).")
            #endif
        } catch {
            loadError = "Parking data couldn't be loaded. \(error.localizedDescription)"
            print("❌ parking_spots.json failed to load: \(error)")
        }
    }

    private func loadLandmarks() {
        do {
            let all: [Landmark] = try Self.decode("landmarks")
            landmarks = all.filter { $0.coordinate != nil }
            let missing = all.count - landmarks.count
            if missing > 0 {
                print("⚠️ \(missing) landmarks have null coordinates and are hidden. Fill them in landmarks.json.")
            }
        } catch {
            print("❌ landmarks.json failed to load: \(error)")
        }
    }

    private func computeCampusBounds() {
        guard !lots.isEmpty else { return }
        let lats = lots.map(\.coordinate.latitude)
        let lons = lots.map(\.coordinate.longitude)
        let center = CLLocationCoordinate2D(latitude: (lats.min()! + lats.max()!) / 2,
                                            longitude: (lons.min()! + lons.max()!) / 2)
        campusCenter = center
        campusRegion = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: (lats.max()! - lats.min()!) * 1.4,
                                   longitudeDelta: (lons.max()! - lons.min()!) * 1.4)
        )
    }

    private static func decode<T: Decodable>(_ name: String) throws -> T {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSLocalizedDescriptionKey: "\(name).json is missing from the app bundle."])
        }
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }
}
