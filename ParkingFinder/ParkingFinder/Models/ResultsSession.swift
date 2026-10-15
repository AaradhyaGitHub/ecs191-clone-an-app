import Foundation

/// The drive-time cell on a lot card.
enum DriveTime: Equatable {
    case loading
    case minutes(Int)
    /// MapKit couldn't answer, so show the straight-line distance instead.
    case straightLine(meters: Double)
    /// No ETA and no user location to measure from.
    case unavailable
}

/// Everything the results sheet shows for one search.
struct ResultsSession: Identifiable {
    enum Origin: Equatable {
        case user
        case landmark(Landmark)
    }

    let id = UUID()
    let origin: Origin
    /// nil while waiting for the user's location (the loading state).
    var lots: [Lot]?
    var driveTimes: [String: DriveTime] = [:]
    var selectedIndex = 0

    var landmark: Landmark? {
        if case .landmark(let landmark) = origin { return landmark }
        return nil
    }
}
