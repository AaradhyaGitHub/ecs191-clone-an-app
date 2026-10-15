# UC Davis Student Parking Finder

An iOS app that finds the closest student parking at UC Davis and starts driving directions in one tap. It clones the *problem* AMP Park solves (where can I legally park, and how do I get there?) without payments. Built in Swift + SwiftUI for ECS 191.

> Draft README written with Claude Code. Edit before submitting.

## Build

**Requirements:** Xcode 27 (built and tested with Xcode 27.0 and the iOS 27 simulator). Deployment target iOS 17.0. No third-party dependencies: only SwiftUI, MapKit, CoreLocation and Foundation.

1. Clone the repo and open `ParkingFinder/ParkingFinder.xcodeproj`.
2. Pick the **ParkingFinder** scheme and an iPhone simulator (e.g. iPhone 17).
3. Press **Run** (⌘R).
4. In the simulator, set a location in Davis: **Features → Location → Custom Location…** (any point on campus).

From the terminal:

```sh
xcodebuild -project ParkingFinder/ParkingFinder.xcodeproj -scheme ParkingFinder -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project ParkingFinder/ParkingFinder.xcodeproj -scheme ParkingFinder -destination 'platform=iOS Simulator,name=iPhone 17' test
```

If `xcodebuild` complains about Command Line Tools, run
`sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.

## How to use

- **Find parking near me.** Tap the big navy button. You get the 3 closest student lots (zones C and L), each with the drive time if you leave in 10 minutes. Tap a card or a numbered pin to highlight it.
- **Navigate.** Tap **Navigate** on a card. Apple Maps opens with driving directions. If Google Maps is installed, you can choose between the two (and have the app remember your choice).
- **Search a building.** Tap the search bar and type a building or a nickname ("Olson", "MU", "ARC"). Picking one shows the 3 lots closest to *that building*, with walking time from each lot.
- **Explore the map.** Zoom with pinch or the + / − buttons. The map has six levels: campus areas and clusters (rings show the share of C and L lots), then individual lots, then lot names, then the lot you're standing in. Tap any marker to zoom in on it.

The app also handles location being off, being far from Davis, and missing data.

## Data

- Lot data (`parking_spots.json`) was hand-collected from the AMP Park map and cross-checked with Google Maps, updated 2026-10-14. It covers roughly 70% of Davis. Zones can change; check TAPS for the official rules.
- Nearby points from the same lot (within 50 m) are grouped so the 3 results are 3 different lots.
- Which zones count as student parking is set in one place: `Config.studentZones` (currently C and L).
- Campus buildings are in `landmarks.json`. Buildings without coordinates are hidden.

## Project layout

```
ParkingFinder/ParkingFinder/
  App/        app entry, Config (tunable values), Theme (design colors)
  Models/     ParkingSpot (matches the JSON), Lot, Landmark, ResultsSession
  Services/   DataStore, LocationManager, Ranking (Haversine), DriveTimeService,
              Navigator, LandmarkSearch, Formatters
  Views/      HomeView, ResultsSheet, SearchView, LocationPrimerView
    Map/      CampusMapView, zoom levels, clustering, markers, controls
    Components/  buttons, cards, pins, tags, sheets
  Resources/  parking_spots.json, landmarks.json
ParkingFinder/ParkingFinderTests/RankingTests.swift
design/       design hand-off (specs and screen references)
```
