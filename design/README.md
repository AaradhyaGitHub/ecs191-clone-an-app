# Design handoff: UC Davis Student Parking Finder

Drop this whole folder into the root of your Xcode project repo (e.g. as `design/`),
then give Claude Code the prompt below.

## What's inside

| Path | What it is |
|---|---|
| `SPEC.md` | Product spec: behavior, logic, data, states (the source of truth for behavior) |
| `DESIGN_SPEC.md` | Design spec: colors, type, components, every screen, the 6-level map zoom system, motion, copy |
| `design-source/*.dc.html` | One file per screen from the design canvas. HTML with inline styles: read them for exact sizes and colors. Not code to port. |
| `design-source/MapLive.dc.html` | Interactive map reference. Its script block holds the zoom-level table, marker data and animation timings. |
| `design-source/canvas.json` | Which file is which screen (titles and order) |
| `screenshots/` | Optional: put PNG exports of the artboards here (see below) |

## Optional: add screenshots

Claude Code works best with pictures too. On the design canvas, use
Share › Export to save the artboards as PNGs, put them in `screenshots/`, and keep
the file names matching the `.dc.html` names (e.g. `Results.png`).

## Prompt for Claude Code

```
Read design/README.md, design/SPEC.md and design/DESIGN_SPEC.md, then look at
the files in design/design-source/ (and design/screenshots/ if present).

Build the iOS app described in SPEC.md as a native SwiftUI + MapKit app
(iOS 17 deployment target, no third-party packages). Match DESIGN_SPEC.md for
visuals: put the color tokens in an asset catalog or a Theme.swift with light
and dark variants, and build the reusable components first (SearchBarButton,
PrimaryButton, LotCard, ZoneTag, NumberedPin, ResultsSheet, StateCard,
LandmarkRow, MapsChoiceSheet).

Then build the screens in this order:
1. Home map + location permission primer + denied / far-away states
2. Ranking (Haversine, studentZones filter) and the Results sheet with ETAs
   (MKDirections calculateETA, departure now + 10 min, straight-line fallback)
3. Search with alias matching and landmark-based results with walk times
4. Navigate (Apple Maps, plus Google Maps choice if installed)
5. The 6-level map zoom system from DESIGN_SPEC.md section 4, with zone
   polygons, area/cluster donuts, lot markers and the motion described there

Create sample lots.json and landmarks.json with the extended schema in
DESIGN_SPEC.md section 5, using clearly marked placeholder coordinates I will
replace. Treat the HTML files as visual reference only; do not embed web views.
Write a README.md with build steps and how to use the main features.
Commit after each step.
```

## Notes

- All lot names, zones, counts, times and coordinates in the design are sample data.
- `SPEC.md` says Xcode 16.3; the course requires the project to build in the
  Xcode version named in the assignment. Tell Claude Code which one you're using.
