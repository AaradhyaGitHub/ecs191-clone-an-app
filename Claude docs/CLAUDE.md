# CLAUDE.md — Project Brief: UC Davis Student Parking Finder

Read this whole file before writing any code. Supporting material lives in `docs/` and `proposal.md`.

## 0. Hard constraints (non-negotiable)

- **Native iOS app written in Swift, UI in SwiftUI.**
- **No JavaScript, React Native, Flutter, web views, or any cross-platform tooling.** The course forbids it.
- **No third-party packages** (no SPM, CocoaPods, or Carthage dependencies). Apple frameworks only: SwiftUI, MapKit, CoreLocation, Foundation.
- **Toolchain:** the developer has **Xcode 16.3** (Swift 6.1, iOS 18.4 simulator) on macOS Sequoia 15.2. The grader builds with **Xcode 27**. So:
  - Deployment target **iOS 17.0**.
  - Use only APIs available in the iOS 18.4 SDK. **Do not use any iOS 26+ APIs.**
  - Keep the project a plain Xcode project that opens cleanly in newer Xcode.
- **The developer must understand every line of code.** This is an academic integrity requirement (see `docs/assignment.md`). Therefore:
  - Prefer simple, readable code over clever code. No unnecessary abstractions.
  - Keep files small and single-purpose.
  - Add short comments explaining *why* where it isn't obvious.
  - After each milestone, give a plain-English summary of what each new or changed file does.
- **Never write `proposal.md` or `user_testing.md`.** Those must be the student's own writing. Don't edit `proposal.md`.
- **Never invent coordinates.** Do not fill in lat/lon for lots or landmarks from memory. If a coordinate is missing, leave it `null` and tell the developer.

## 1. Context

This is the ECS 191 "Clone an app" homework, Part 2: a working first cut, due very soon. The app clones the *problem* AMP Park solves at UC Davis, not its features. See `proposal.md` and `docs/assignment.md`.

**Scope decision:** the professor noted there's no known public API for buying UC Davis parking (`docs/professor_feedback.md`). So **this app does not handle payments.** It focuses on the map and recommendation side: "Where should I park, and how do I get there?"

**Core loop:** open the app → tap one button (or search a campus building) → see the 3 closest student-eligible lots with drive times → tap Navigate → the maps app opens with directions.

Speed matters more than polish. Get the core loop working end to end first.

## 2. Project setup

The developer creates the Xcode project by hand in Xcode (File → New → Project → iOS App, Interface: SwiftUI, Language: Swift). Work inside that project; don't generate a new `.xcodeproj` or use XcodeGen.

- Build from the terminal with something like:
  `xcodebuild -scheme <SchemeName> -destination 'platform=iOS Simulator,name=iPhone 16' build`
  (If `xcodebuild` fails with a Command Line Tools error, tell the developer to run
  `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`.)
- Add `NSLocationWhenInUseUsageDescription` to the target's Info settings, e.g.
  "Used to find parking lots near you."
- If the optional Google Maps choice is built, add `comgooglemaps` to `LSApplicationQueriesSchemes`.
- Bundle `lots.json` and `landmarks.json` as app resources (check they're in the target's Copy Bundle Resources).

## 3. Data

### lots.json (already exists — provided by the developer)
The developer hand-collected the lot data from the AMP Park map and cleaned it into JSON.

1. **Open the real `lots.json` first and inspect its actual structure.** Do not assume the schema below.
2. Write a `Codable` model that matches the file **as it is.** Don't reformat or rewrite the data file without asking.
3. Report to the developer: number of entries, fields found, distinct zone values found, and any entries with missing or odd values.

Suggested target shape (for reference only):
```json
[{ "id": "lot-47", "name": "Lot 47", "zones": ["C","L"],
   "type": "surface", "lat": 38.0, "lon": -121.0 }]
```
The data may contain **several entries per physical lot** (one per AMP zone point). If so, group them so the 3 results are 3 *different* lots: group by lot name/id if a field exists; otherwise treat entries within ~50 m of each other as the same lot. Ask the developer which approach fits the data.

### landmarks.json (to create)
Create the file with this structure. Fill in **names and aliases only**; set `lat`/`lon` to `null` for the developer to fill in from Google Maps. The app must skip landmarks with null coordinates.
```json
[{ "id": "mu", "name": "Memorial Union", "aliases": ["MU"], "lat": null, "lon": null }]
```
Starter names: Memorial Union, Shields Library, The Silo, Olson Hall, Wellman Hall, Kemper Hall, Cruess Hall, Giedt Hall, Activities and Recreation Center (ARC), Mondavi Center, Rec Pool, Sciences Lecture Hall, Haring Hall, Hutchison Hall, The Pavilion (Pav), Student Community Center, Arboretum (Putah Creek Lodge), Death Star (Social Sciences and Humanities), Sol at West Village, Tercero, Segundo, Cuarto.

### Student eligibility
Put the eligible zones in **one** configurable place:
```swift
enum Config {
    // TODO(developer): confirm against TAPS daily rates page.
    static let studentZones: Set<String> = []
}
```
Leave it for the developer to fill in. If it's empty at runtime, show all lots and log a warning, so the app still works.

## 4. Screens

### Screen 1 — Home (map)
- Full-screen SwiftUI `Map` (iOS 17 MapKit for SwiftUI) centered on the user's location (`UserAnnotation`), zoomed to roughly campus scale.
- Uncluttered: `.mapStyle(.standard(pointsOfInterest: .excludingAll))`. Lot markers hidden by default, or shown as small subtle dots.
- Top: rounded search bar, placeholder "Search UC Davis buildings…". Tapping opens Screen 3.
- Bottom: one large primary button: **"Find student parking near me"**.
- No other buttons, tabs, or menus.

### Screen 2 — Results (3 cards)
- Triggered by the primary button (origin = user location) or by picking a landmark (origin = landmark).
- Show a short loading state ("Finding nearby lots…") while drive times load.
- Map zooms to fit the origin and the 3 lots; lots get numbered pins 1, 2, 3.
- Bottom sheet with 3 cards, closest first. Each card shows:
  - Lot name
  - Zone badges (e.g., `C`, `L`)
  - Drive time if leaving in 10 minutes, e.g. "6 min drive" (placeholder "…" while loading)
  - In landmark mode only: "about N min walk to <landmark>"
  - Full-width **Navigate** button
- Tapping a card highlights its pin; tapping a pin highlights its card.
- A close button returns to Screen 1.

### Screen 3 — Search (full screen)
- Full-screen view, keyboard up, Cancel button.
- Empty query: "Popular on campus" list of landmarks, sorted by distance from the user (or alphabetically if location is unavailable). Each row shows name and distance.
- Typing filters by name and aliases, case-insensitive, partial match ("mu" → Memorial Union).
- Tapping a landmark goes to Screen 2 with that landmark as origin.
- No matches: "No campus building found".

## 5. Logic

- **Ranking:** Haversine distance from origin to each eligible lot; take the 3 closest distinct lots. Put Haversine in its own small pure function and unit test it with a known distance.
- **Drive time:** for each of the 3 lots, `MKDirections.Request` with `transportType = .automobile`, source = user's current location, destination = lot, `departureDate = Date().addingTimeInterval(600)`; use `calculateETA()`. Run the 3 requests concurrently. Only request ETAs for the 3 shown lots (MapKit throttles). If an ETA fails, show the straight-line distance instead. **Never block the cards on ETA.**
- **Walking (landmark mode):** Haversine from lot to landmark ÷ ~80 m/min, labeled "about".
- **Navigate:** open Apple Maps with driving directions from current location to the lot using `MKMapItem(placemark:)` + `openMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])`. Optional: if Google Maps is installed (`UIApplication.shared.canOpenURL` with `comgooglemaps://`), show a choice of Apple Maps or Google Maps.

## 6. States to handle
- Location not yet authorized: brief explanation, then the system prompt.
- Location denied: message, a button opening Settings, and a note that search still works.
- User more than ~15 km from campus: "You're not near UC Davis", suggest search instead.
- Fewer than 3 eligible lots: show what's available.
- `lots.json` missing or fails to decode: clear error message (and log the decoding error).

## 7. Visual style
- Light and dark mode. System font. Accent colors: UC Davis navy `#022851`, gold `#FFBF00` for highlights.
- Generous spacing, rounded cards, soft shadows. 44pt minimum tap targets. Supports Dynamic Type.
- Designs are being made separately in Claude Design; if the developer provides screenshots or specs from there, match them.

## 8. Suggested structure
```
App/
  ParkingApp.swift          // @main entry
  Config.swift              // studentZones etc.
Models/
  Lot.swift                 // Codable, matches lots.json
  Landmark.swift
Services/
  DataStore.swift           // loads JSON from bundle
  LocationManager.swift     // CoreLocation wrapper (@Observable)
  Ranking.swift             // haversine + topLots(...)
  DriveTimeService.swift    // MKDirections ETA
  Navigator.swift           // opens Apple/Google Maps
Views/
  HomeView.swift
  ResultsSheet.swift
  LotCard.swift
  SearchView.swift
Resources/
  lots.json
  landmarks.json
Tests/
  RankingTests.swift
```
Use `@Observable` (iOS 17) for state. Keep view models minimal.

## 9. Milestones (stop and summarize after each; commit after each)
1. Load and decode `lots.json`; print a data report. Create `landmarks.json` skeleton.
2. Haversine + ranking + unit tests.
3. Home map with user location, search bar (non-functional), primary button.
4. Results: 3 cards from ranking, numbered pins, Navigate opens Apple Maps.
5. Drive-time ETAs on the cards.
6. Search screen with landmark list, filtering, and landmark-mode results.
7. Edge states (permission denied, far away, errors).
8. Draft `README.md` (developer will edit): build steps (Xcode version, scheme, simulator), how to use the main features, data source note ("lot data hand-collected from the AMP Park map, <date>"), and tested toolchain ("Developed with Xcode 16.3 / iOS 18.4 simulator; no third-party dependencies").

If time runs short, milestones 1–4 plus 8 are the minimum viable submission.

## 10. Out of scope
Payments, accounts, vehicles, parking sessions, notifications, live availability, heatmaps, class-schedule integration, enforcement-sighting features.

## 11. Definition of done
- Builds with no errors from a clean clone in Xcode 16.3, with no third-party dependencies.
- Core loop works in the simulator (set a simulated location in Davis via Features → Location).
- `README.md` exists with build and usage instructions.
- The developer can explain every file.
