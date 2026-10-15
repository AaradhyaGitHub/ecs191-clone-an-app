import MapKit

/// Builds map regions. Kept separate from the views because it's just math.
enum CameraMath {
    /// A region of `latitudeDelta` around `center`, with a longitude span that
    /// matches the screen shape so MapKit doesn't zoom out to fit a wide box.
    static func region(center: CLLocationCoordinate2D, latitudeDelta: Double, screen: CGSize) -> MKCoordinateRegion {
        let aspect = screen.height > 0 ? screen.width / screen.height : 0.46
        let lonDelta = latitudeDelta * aspect / cos(center.latitude * .pi / 180)
        return MKCoordinateRegion(center: center,
                                  span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: lonDelta))
    }

    /// A region that fits `points` into the part of the screen *above* the
    /// bottom sheet (and below the status bar), with some breathing room.
    static func fit(_ points: [CLLocationCoordinate2D], screen: CGSize, topInset: CGFloat, bottomCover: CGFloat) -> MKCoordinateRegion? {
        guard !points.isEmpty, screen.height > 0 else { return nil }
        let lats = points.map(\.latitude), lons = points.map(\.longitude)
        let boxCenterLat = (lats.min()! + lats.max()!) / 2
        let boxCenterLon = (lons.min()! + lons.max()!) / 2
        let boxLat = lats.max()! - lats.min()!
        let boxLon = lons.max()! - lons.min()!
        let cosLat = cos(boxCenterLat * .pi / 180)

        // Fraction of the screen height that is actually visible.
        let visible = max((screen.height - bottomCover - topInset) / screen.height, 0.2)
        // Latitude span needed for the box's height, and for its width (converted to "latitude" units).
        let forHeight = boxLat * 1.6 / visible
        let forWidth = boxLon * 1.35 * cosLat * (screen.height / screen.width)
        let latSpan = max(forHeight, forWidth, 0.004)

        // Shift the camera down so the box sits in the middle of the visible band.
        let shiftPoints = (bottomCover - topInset) / 2
        let centerLat = boxCenterLat - latSpan * Double(shiftPoints / screen.height)
        return region(center: CLLocationCoordinate2D(latitude: centerLat, longitude: boxCenterLon),
                      latitudeDelta: latSpan, screen: screen)
    }
}
