import MapKit
import UIKit

enum MapsApp: String {
    case apple, google
}

/// Hands off driving directions to Apple Maps or Google Maps.
@MainActor
enum Navigator {
    private static let googleScheme = URL(string: "comgooglemaps://")!

    /// Needs `comgooglemaps` in LSApplicationQueriesSchemes (Info.plist), or this is always false.
    static var isGoogleMapsInstalled: Bool {
        UIApplication.shared.canOpenURL(googleScheme)
    }

    static func directions(to lot: Lot, using app: MapsApp) {
        switch app {
        case .apple:
            let item = MKMapItem(placemark: MKPlacemark(coordinate: lot.coordinate))
            item.name = lot.name
            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        case .google:
            // No "saddr" means Google Maps starts from the current location.
            let lat = lot.coordinate.latitude, lon = lot.coordinate.longitude
            if let url = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving") {
                UIApplication.shared.open(url)
            }
        }
    }
}
