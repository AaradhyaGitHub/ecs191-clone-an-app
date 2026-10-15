# Spec: UC Davis Student Parking Finder (iOS, SwiftUI)

## Purpose
Help a UC Davis student find the closest student-eligible parking lots to where they are
(or to a campus landmark) and start navigation in one tap. No payments, no accounts.

## Constraints
- Native iOS, SwiftUI only. MapKit + CoreLocation. No third-party packages.
- Must build in Xcode 16.3; deployment target iOS 17.
- Data is bundled locally: lots.json and landmarks.json. No network APIs except MapKit's.

## Screen 1: Home (map)
- Full-screen map centered on the user's location (blue dot), zoomed to roughly campus scale.
- Clean and uncluttered: hide Apple's points of interest
  (`.mapStyle(.standard(pointsOfInterest: .excludingAll))`). Lot markers are hidden by default
  or shown as small, subtle dots.
- Top: a rounded search bar, "Search UC Davis buildings…". Tapping it opens Screen 3.
- Bottom: one large primary button, "Find student parking near me".
- No other buttons, tabs, or menus.

## Screen 2: Results (3 lot cards)
- Triggered by the primary button.
- Brief loading state ("Finding nearby lots…") while drive times load.
- The map zooms to fit the user and the 3 lots; the 3 lots get numbered pins (1, 2, 3).
- Bottom sheet with 3 cards, closest first. Each card shows:
  - Lot name (e.g., "Lot 47" or "Gateway Structure")
  - Zone badges (e.g., C, L)
  - Drive time if leaving in 10 minutes (e.g., "6 min drive")
  - A full-width "Navigate" button
- Tapping a card's pin or body highlights it on the map. Tapping Navigate opens maps (see Navigation).
- A close/back control returns to Screen 1.

## Screen 3: Search (full screen)
- Opens as a full-screen view with the keyboard up and a Cancel button.
- Empty query: a "Popular on campus" list of UC Davis landmarks
  (e.g., Memorial Union, Shields Library, the Silo, Olson Hall, ARC, Mondavi Center),
  sorted by distance from the user, each row showing name and distance.
- Typing filters the landmark list (case-insensitive, matches partial names and aliases,
  e.g., "MU" → Memorial Union).
- Tapping a landmark returns to Screen 2, but ranks the 3 closest lots to that landmark
  instead of to the user. Cards also show the walking distance from lot to landmark.
- No results: "No campus building found" plus a short hint.

## Logic
- Eligibility: filter lots to student-eligible zones from a configurable list
  `studentZones` (set by the developer in one place).
- Ranking: Haversine distance from origin (user location, or the chosen landmark) to each lot;
  take the top 3.
- Drive time: `MKDirections.Request` with transportType = .automobile and
  departureDate = now + 10 minutes; use `calculateETA`. If it fails, show
  straight-line distance instead of a time. Never block the cards on ETA.
- Walking distance (landmark mode only): Haversine from lot to landmark, shown as
  minutes at about 80 m/min plus meters, labeled "about".

## Navigation
- Navigate opens Apple Maps with driving directions from current location to the lot,
  via `MKMapItem.openMaps(with:launchOptions:)` with `MKLaunchOptionsDirectionsModeDriving`.
- Optional: if Google Maps is installed (`comgooglemaps://`, declared in
  `LSApplicationQueriesSchemes`), show a small choice sheet: Apple Maps / Google Maps.

## Data formats
lots.json:
```json
[{ "id": "lot-47", "name": "Lot 47", "zones": ["C","L"],
   "type": "surface", "lat": 38.5380, "lon": -121.7540 }]
```
landmarks.json:
```json
[{ "id": "mu", "name": "Memorial Union", "aliases": ["MU"],
   "lat": 38.5423, "lon": -121.7497 }]
```
(The coordinates above are placeholders, not real values.)

## States to handle
- Location permission not yet asked: explain why before the system prompt.
- Location denied: show a message, a button to open Settings, and say search still works.
- User far from Davis (more than 15 km): "You're not near UC Davis", offer search instead.
- Fewer than 3 eligible lots: show what's available.

## Visual style
- Light and dark mode. System font (SF Pro). One accent color (UC Davis navy #022851,
  gold #FFBF00 for highlights). Generous spacing, rounded cards, soft shadows.
- Large tap targets (44pt minimum). Supports Dynamic Type.

## Out of scope
Payments, accounts, vehicles, notifications, live availability, class schedules.
