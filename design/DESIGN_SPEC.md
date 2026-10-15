# UC Davis Student Parking Finder — Design Spec (SwiftUI handoff)

This is the design-to-code spec for the iOS app. It complements the product spec
(`SPEC.md`, the original "Spec: UC Davis Student Parking Finder"). Where they
disagree, the product spec wins on **behavior** and this file wins on **visuals**.

Design source: `design-source/*.dc.html`. Each file is one phone screen
(390 × 844 pt, iPhone 15/16 size) written as HTML with inline styles. Treat them as
**visual reference only**: read the inline styles for exact sizes, colors, radii
and spacing, then rebuild natively in SwiftUI + MapKit. Do not port HTML/JS.
The map drawn in the HTML is a fake illustration; the real app uses MapKit.

All lot names, zone shapes, counts, drive times and distances in the design are
**sample data**. Real values come from `lots.json` / `landmarks.json`.

---

## 1. Design tokens

### Colors

| Token | Light | Dark | Use |
|---|---|---|---|
| `navy` | `#022851` | `#022851` | Primary buttons, numbered pins, brand |
| `gold` | `#FFBF00` | `#FFBF00` | Selected pin/card, icon accents on navy, dark-mode primary button |
| `ink` | `#0E1726` | `#F2F4F7` | Primary text |
| `inkSecondary` | `#4A5565` | `#A7B0BE` | Secondary text (≥ 4.5:1 on surfaces) |
| `inkBody` | `#2B3442` | `#C9D0DA` | Body copy in cards |
| `placeholder` | `#5A6472` | `#8C96A5` | Search placeholder |
| `surface` | `#FFFFFF` | `#1A1F28` | Cards, search bar, sheets' cards |
| `sheet` | `#F4F5F7` | `#0B0F15` | Bottom-sheet background |
| `hairline` | `#E3E6EA` | `#2A3240` | Dividers |
| `chipFill` | `#E4E7EC` | `#232A35` | Close button background |
| `tileFill` | `#E7ECF4` | `#26324A` | Icon tiles, zone badges (navy text on it) |
| `skeleton` | `#E6E9EE` | `#2A3240` | Loading placeholders |
| `userBlue` | `#1E7BF2` | `#3B8CFF` | User location dot |
| `zoneC` | `#2563D9` | `#5B93F0` | Zone C (commuter) fills/strokes |
| `zoneCTagBg` / `zoneCTagFg` | `#DCE7FB` / `#1A4FB5` | `#26324A` / `#D3DEF2` | "C" letter tag |
| `zoneL` | `#E07A1A` | `#E89A4F` | Zone L (resident) fills/strokes |
| `zoneLStroke` | `#C4650E` | `#E89A4F` | L polygon outline |
| `zoneLTagBg` / `zoneLTagFg` | `#FCE6CF` / `#8A4300` | `#4A3218` / `#FCE6CF` | "L" letter tag |
| `zoneOther` | `#8C95A3` | `#6B7380` | Non-student zones (dashed outline, grey dots) |
| `warnTile` | `#FFF1C2` | `#3A3016` | Icon tile on "Location is off" |

The C blue and L orange pair was checked for color-blind separation (they differ
in lightness, not just hue). Never show zone identity by color alone: always pair
the color with the letter tag.

### Typography (SF Pro via `.font(.system(...))`; support Dynamic Type)

| Role | Size / weight | SwiftUI |
|---|---|---|
| Permission headline | 30 / heavy, tracking −0.6 | `.system(size: 30, weight: .heavy)` → scale with `.largeTitle` |
| Sheet title | 20 / bold | `.title3.bold()` |
| Card title / lot name | 17 / semibold | `.headline` |
| Drive time | 22 / bold, tracking −0.3 | `.title2.bold()` |
| Body | 15–17 / regular | `.body` / `.subheadline` |
| Caption ("drive", subtitles) | 12–13 / regular | `.caption` / `.footnote` |
| Section header ("POPULAR ON CAMPUS") | 13 / bold, uppercase, tracking 0.6 | `.footnote.bold()` + `.textCase(.uppercase)` |
| Zone tag letter | 13 / heavy | `.footnote.weight(.heavy)` |

### Shape, spacing, elevation

- Screen side padding: 16. Bottom safe area: 34 (use real safe-area insets).
- Radii: search bar 26 (capsule), primary button 18, sheet top 24, cards 18,
  card buttons 12, icon tiles 10–12, zone tags 6, action sheet panels 16.
- Tap targets ≥ 44 pt everywhere.
- Shadows (light mode): floating controls `navy @ 12%, radius 16, y 4`;
  primary button `navy @ 28%, radius 24, y 8`; pins `navy @ 35%, radius 10, y 4`.
  Use near-zero shadows in dark mode.
- Card gap 10; sheet inner gap 14.

---

## 2. Reusable components

| Component | Spec | Seen in |
|---|---|---|
| `SearchBarButton` | White capsule, h 52, top 62 from screen top, magnifier icon (navy) + "Search UC Davis buildings…". Tapping opens Search (full screen). | Main, LocationDenied, FarAway, MapLive |
| `PrimaryButton` | Navy, h 60, radius 18, gold location-arrow icon + white 17 semibold label. Pinned 34 pt above bottom safe edge. | Main, MapLive, LocationAsk |
| `LotCard` | White, radius 18, padding 14/16, 2 pt border (gold when selected, else surface color). Row: numbered badge (32 circle) · name + zone tags · drive time (22 bold) over "drive". Full-width Navigate button (h 46, navy, gold arrow). Landmark mode adds a walk line: walk icon + "About 4 min walk (320 m) to Olson". | Results, LandmarkResults, ResultsDark |
| `NumberedPin` | Map annotation: circle 34 (selected 40), 3 pt white border, navy fill + white number; selected = gold fill + navy number, drawn on top. | Results, LandmarkResults |
| `ZoneTag` | 22×22 (min width 24), radius 6, letter in tag fg on tag bg. | Cards, map lot markers |
| `ResultsSheet` | Grabber 36×5, title + subtitle ("Drive times if you leave in 10 min"), 44 pt close button (X, chipFill). Fixed height so the map keeps the top ~280 pt. Use `.sheet` with `.presentationDetents([.height(567)])` and `.presentationBackgroundInteraction(.enabled)` or a custom overlay. | Results, Loading |
| `StateCard` | Floating white card over the map (radius 22, padding 20): 44 tile icon + title (19 bold) + body, then one full-width button (h 52, radius 14). | LocationDenied, FarAway |
| `LandmarkRow` | h ≥ 64: 40 tile with building icon · name (17 semibold) + optional subtitle (13) · distance "1.3 mi" right. Hairline divider. | Search |
| `MapsChoiceSheet` | iOS-style action sheet: title "Directions to {lot}", subtitle "Driving, from your current location", rows "Apple Maps" / "Google Maps", "Remember my choice" toggle, separate Cancel. Use `.confirmationDialog` or a custom sheet. Only shown if Google Maps is installed. | NavigateSheet |

Icons: use SF Symbols, e.g. `magnifyingglass`, `location.fill`, `xmark`,
`building.2`, `figure.walk`, `car.fill`, `map`, `location.slash`, `gearshape`,
`plus`, `minus`.

---

## 3. Screens (match file → SwiftUI view)

| # | File | View | Notes |
|---|---|---|---|
| 1 | `Main.dc.html` | `HomeView` | Full-screen map, user centered, POIs hidden (`.mapStyle(.standard(pointsOfInterest: .excludingAll))`). Only the search bar and primary button. The map follows the zoom system in §4. |
| 2a | `Loading.dc.html` | `ResultsView(state: .loading)` | Same sheet size as results; spinner + "Finding nearby lots…" + "Checking drive times for leaving in 10 min"; 3 skeleton cards with a soft shimmer. Show cards as soon as ranking is done and fill in drive times as ETAs arrive (never block on ETA). |
| 2b | `Results.dc.html` | `ResultsView` | Map fits the user + 3 pins. First card selected by default. Tapping a card or pin selects it (gold). |
| 2c | `NavigateSheet.dc.html` | `MapsChoiceSheet` | See component. |
| 3a | `Search.dc.html` | `SearchView` | Full screen, focused field with a 2 pt navy border, Cancel. Empty query → "POPULAR ON CAMPUS · Nearest first" list. |
| 3b | `SearchTyping.dc.html` | same | Query "mu" → Memorial Union with subtitle "Matches “MU”" (alias match). Clear button inside the field. |
| 3c | `SearchEmpty.dc.html` | same | "No campus building found" + hint "Try a building name like “Olson” or a nickname like “MU”. Only UC Davis campus places are listed." |
| 3d | `LandmarkResults.dc.html` | `ResultsView(origin: .landmark)` | Title "Parking near {landmark}", landmark marker (navy square + name chip), cards include walk line. |
| 4a | `LocationAsk.dc.html` | `LocationPrimerView` | Shown before the system prompt. "Continue" triggers `requestWhenInUseAuthorization()`; "Search a building instead" opens Search. |
| 4b | `LocationDenied.dc.html` | `HomeView` + `StateCard` | "Location is off" + "Open Settings" (`UIApplication.openSettingsURLString`). Search still works. |
| 4c | `FarAway.dc.html` | `HomeView` + `StateCard` | Shown when the user is > 15 km from campus. Button opens Search. |
| 4d | `ResultsDark.dc.html` | dark mode reference | Selected card's Navigate button is gold with navy text; the others are `#2A3344`. Card 3 shows the ETA fallback: "1.5 mi" over "straight-line". |
| 5 | `MapLive.dc.html` | Map zoom system | Interactive reference for §4. Its `renderVals()` script holds the level table, marker data and animation timings. |

---

## 4. Map zoom system (6 levels)

The map changes what it shows based on zoom. Read the current camera with
`.onMapCameraChange(frequency: .continuous)` and derive a level from
`context.region.span.latitudeDelta` (tune these thresholds on device):

| Level | Name | Approx. latitudeDelta | Shows |
|---|---|---|---|
| 0 | City | > 0.06 | 2 area markers ("Main campus", "South campus") + muted neighborhood labels |
| 1 | Campus areas | 0.035 – 0.06 | ~5 area markers (Segundo, Central campus, West Village, Tercero, South campus) |
| 2 | Clusters | 0.02 – 0.035 | Areas split into smaller clusters (e.g. Central → North, Quad, Arboretum) |
| 3 | Lots | 0.012 – 0.02 | One compact marker per student lot (zone tags only); non-student lots as small grey dots; legend gains "not for students" |
| 4 | Lots + zones | 0.006 – 0.012 | Lot markers expand to show names; zone polygons appear at ~55% opacity |
| 5 | Your zone | < 0.006 | Zone polygons at full strength with one label each; the zone the user is inside is highlighted and "breathes"; a card slides up: "You're in {lot}" / "Zone {X} · open to {X} permit holders" |

**Area / cluster marker ("donut").** Navy circle with the lot count in white
(20 bold if ≥ 20, else 16), a white halo, and a 5 pt ring split into a blue arc
(share of C lots) and an orange arc (share of L lots) with 3 pt gaps between arcs.
Radius by count: ≥ 40 → 34, ≥ 20 → 30, ≥ 8 → 24, else 21. Area name below in 13 bold
with a white text halo. Tapping zooms one level in, centered on the marker.
Build it as a SwiftUI view inside `Annotation` (two `Circle().trim(from:to:)` strokes,
rotated −90°).

**Lot marker.** White rounded rect (radius 10, h 32) with zone tags, a small
pointer tail, anchored at the bottom. At level 4 the name slides open beside the
tags (animate width). Tap → zoom one level in on that lot.

**Zone polygons.** `MapPolygon(coordinates:)` from each lot's `polygon`.
- C: fill `zoneC` @ 12%, stroke `zoneC` 2 pt.
- L: fill `zoneL` @ 16%, stroke `zoneLStroke` 2 pt.
- Non-student (A, F, visitor…): fill grey @ 8%, stroke `zoneOther` 1.5 pt dashed.
- The user's current zone: fill 22–40% with a slow breathing animation, stroke 3 pt.
- Polygons never overlap; if your data has adjacent lots, inset them slightly so a
  thin map-colored gap shows between them.
- One label per zone at its center: white capsule, tag + name; the current zone's
  label gets a 2 pt `zoneC` ring.

**Overlap rule.** At levels 0–2, never draw individual lots. If two markers would
overlap on screen at any level, merge them into a cluster marker with a count.

**Controls (right edge).** White column (w 48, radius 16): `+` button, a
vertical 6-dot level indicator (current dot is gold and taller), `−` button.
A small navy capsule label with the level name sits to the left of the current
dot and slides when the level changes. A round "locate" button below jumps to
level 5 on the user. Legend capsule at top-left under the search bar:
"■ C commuter  ■ L resident" (+ "⬚ not for students" from level 3).

**Motion (make it feel alive).**
- Camera moves between levels: `withAnimation(.smooth(duration: 0.7))` on the
  `MapCameraPosition`.
- Markers appear with a spring (`.spring(response: 0.45, dampingFraction: 0.65)`),
  scaling from 0.4 → 1 and fading in, staggered by ~50 ms per marker.
- Donut rings draw in (animate `trim` from 0) ~250 ms after the marker appears.
- User dot: soft pulsing halo (2.2 s loop).
- Current zone: breathing fill (2.4 s loop, `phaseAnimator` or `repeatForever`).
- "You're in…" card: slides up 24 pt + fades in, 250 ms delay.
- Respect Reduce Motion: drop pulses, breathing and staggering when
  `accessibilityReduceMotion` is on.

---

## 5. Data model additions

Extend the product spec's `lots.json` so the map can draw zones and group lots:

```json
[{
  "id": "lot-47",
  "name": "Lot 47",
  "zones": ["C"],
  "type": "surface",
  "lat": 38.0000, "lon": -121.0000,
  "area": "Central campus",
  "cluster": "North",
  "polygon": [[38.0001, -121.0001], [38.0001, -120.9999], [37.9999, -120.9999], [37.9999, -121.0001]]
}]
```

- `studentZones = ["C", "L"]`, defined in one place (e.g. `AppConfig.swift`).
- Non-student lots stay in the file (they are drawn grey); filter by
  `studentZones` only for ranking and results.
- Area and cluster counts are computed from the data, not hard-coded.
- Coordinates above are placeholders.

---

## 6. Copy strings

- Search placeholder: "Search UC Davis buildings…"
- Primary button: "Find student parking near me"
- Loading: "Finding nearby lots…" / "Checking drive times for leaving in 10 min"
- Results title: "Student parking near you" / "Drive times if you leave in 10 min"
- Landmark results: "Parking near {landmark}" / "Closest to {landmark} · drive times if you leave in 10 min"
- Walk line: "About {n} min walk ({m} m) to {landmark short name}"
- ETA fallback: "{x} mi" over "straight-line"
- Permission primer: "Find parking from where you are" / "Your location is used to rank the closest student lots and get drive times from Apple Maps. Only while the app is open. Nothing is saved." / "iOS will ask for permission next."
- Denied: "Location is off" / "Turn it on to see the lots closest to you. Search still works: tap the bar above and pick a building." / "Open Settings"
- Far away: "You're not near UC Davis" / "Nearby results only cover campus lots. Planning ahead? Pick the building you're heading to." / "Search campus buildings"
- No results: "No campus building found" / hint above
- Zone card: "You're in {lot}" / "Zone {X} · open to {X} permit holders"
