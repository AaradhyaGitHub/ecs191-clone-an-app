import SwiftUI

@main
struct ParkingFinderApp: App {
    // Created once and shared with every view through the environment.
    @State private var store = DataStore()
    @State private var location = LocationManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(store)
                .environment(location)
                .tint(Theme.navy)
        }
    }
}
