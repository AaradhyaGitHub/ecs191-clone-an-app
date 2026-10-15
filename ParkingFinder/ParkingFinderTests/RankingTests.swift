import XCTest
import CoreLocation
@testable import ParkingFinder

/// Tests for the pure logic: distance, grouping spots into lots, ranking, and search.
/// The coordinates here are made-up test values, not real campus locations.
final class RankingTests: XCTestCase {

    // MARK: - Haversine

    func testOneDegreeOfLatitudeIsAbout111Kilometers() {
        // On a sphere of radius 6,371 km, 1° of arc = 6,371,000 × π / 180 ≈ 111,195 m.
        let meters = Ranking.haversineMeters(coord(0, 0), coord(1, 0))
        XCTAssertEqual(meters, 111_195, accuracy: 1)
    }

    func testDistanceToSamePointIsZero() {
        XCTAssertEqual(Ranking.haversineMeters(coord(38.5, -121.7), coord(38.5, -121.7)), 0, accuracy: 0.001)
    }

    func testDistanceIsSymmetric() {
        let a = coord(38.53, -121.75), b = coord(38.54, -121.76)
        XCTAssertEqual(Ranking.haversineMeters(a, b), Ranking.haversineMeters(b, a), accuracy: 0.001)
    }

    // MARK: - Grouping

    func testNearbySpotsBecomeOneLotWithBothZones() {
        // 0.0001° of latitude ≈ 11 m apart, so these two are the same lot.
        let spots = [
            spot("a", lat: 10.0000, lon: 20, permits: ["C"]),
            spot("b", lat: 10.0001, lon: 20, permits: ["L"]),
            spot("c", lat: 10.0100, lon: 20, permits: ["A"]), // ≈ 1.1 km away
        ]
        let lots = Ranking.groupIntoLots(spots, within: 50)
        XCTAssertEqual(lots.count, 2)
        XCTAssertEqual(lots[0].zones, ["C", "L"])
        XCTAssertEqual(lots[1].zones, ["A"])
    }

    func testNumberedLotNameWins() {
        let spots = [
            spot("a", lat: 10, lon: 20, permits: ["C"], name: "C Zone / Visitor Parking"),
            spot("b", lat: 10.0001, lon: 20, permits: [], name: "Lot 47 Hourly Parking", lot: 47),
        ]
        XCTAssertEqual(Ranking.groupIntoLots(spots, within: 50).first?.name, "Lot 47 Hourly Parking")
    }

    // MARK: - Ranking

    func testTopLotsAreClosestFirstAndLimited() {
        let lots = Ranking.groupIntoLots([
            spot("far", lat: 10.03, lon: 20, permits: ["C"]),
            spot("near", lat: 10.01, lon: 20, permits: ["C"]),
            spot("mid", lat: 10.02, lon: 20, permits: ["C"]),
            spot("farthest", lat: 10.04, lon: 20, permits: ["C"]),
        ], within: 50)
        let top = Ranking.topLots(lots, near: coord(10, 20), count: 3)
        XCTAssertEqual(top.map(\.id), ["near", "mid", "far"])
    }

    func testFewerLotsThanRequestedReturnsWhatExists() {
        let lots = Ranking.groupIntoLots([spot("only", lat: 10, lon: 20, permits: ["C"])], within: 50)
        XCTAssertEqual(Ranking.topLots(lots, near: coord(10, 20), count: 3).count, 1)
    }

    // MARK: - Search

    func testAliasMatchIsCaseInsensitive() {
        let mu = Landmark(id: "mu", name: "Memorial Union", aliases: ["MU"], subtitle: nil,
                          shortName: nil, lat: 10, lon: 20)
        let results = LandmarkSearch.matches([mu], query: "mu", from: nil)
        XCTAssertEqual(results.first?.landmark.id, "mu")
        // "mu" isn't in "Memorial Union", so it matched the alias and the row says so.
        XCTAssertEqual(results.first?.matchedAlias, "MU")
    }

    func testNoMatchReturnsEmpty() {
        let olson = Landmark(id: "olson", name: "Olson Hall", aliases: [], subtitle: nil,
                             shortName: nil, lat: 10, lon: 20)
        XCTAssertTrue(LandmarkSearch.matches([olson], query: "Wisconsin", from: nil).isEmpty)
    }

    // MARK: - Formatting

    func testWalkLineRoundsToTenMeters() {
        // 320 m ÷ 80 m/min = 4 min.
        XCTAssertEqual(Formatters.walkLine(meters: 318, to: "Olson"), "About 4 min walk (320 m) to Olson")
    }

    // MARK: - Helpers

    private func coord(_ lat: Double, _ lon: Double) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    private func spot(_ id: String, lat: Double, lon: Double, permits: [String],
                      name: String = "Test spot", lot: Int? = nil) -> ParkingSpot {
        ParkingSpot(id: id, name: name, coords: .init(lat: lat, lon: lon), region: nil, area: nil,
                    permits: permits, tags: [], lot: lot, cluster: nil, flags: [], notes: nil)
    }
}
