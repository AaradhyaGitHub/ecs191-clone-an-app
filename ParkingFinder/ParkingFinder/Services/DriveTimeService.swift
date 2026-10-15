import MapKit

/// Asks Apple Maps how long it takes to drive from the user's current location to a lot.
enum DriveTimeService {
    /// Seconds of driving if leaving `Config.departureDelay` from now, or nil if
    /// MapKit can't answer (no location, offline, throttled…).
    static func driveTime(to coordinate: CLLocationCoordinate2D) async -> TimeInterval? {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        request.transportType = .automobile
        request.departureDate = Date().addingTimeInterval(Config.departureDelay)
        do {
            return try await MKDirections(request: request).calculateETA().expectedTravelTime
        } catch {
            print("ETA failed: \(error.localizedDescription)")
            return nil
        }
    }
}
