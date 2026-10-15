# Parking data: research and collection notes

## Is there a public UC Davis car parking dataset?
No dedicated public dataset was found.

- UC Davis runs a public ArcGIS REST server: https://gis.ucdavis.edu/server/rest/services
  - It has `Taps_Bike_Parking` (TAPS bike parking) but **no car parking layer** in the root or `Hosted` folders.
  - Other layers: `UC_Davis_Building_Footprints`, `UC_Davis_Roads_Pathways`, `UCD_Street_Centerlines`, `UC_Davis_Campus_Boundary`, `UCD_Aerials_2022`.
  - Its native coordinate system is NAD83 California State Plane Zone II (feet); use `outSR=4326` to get lat/lon.
- OpenStreetMap (via the Overpass API) has `amenity=parking` data, but quality varies. Not used, for consistency.

## AMP Park
- AMP Park = AIMS Mobile Pay. Web version: https://aimsmobilepay.com
- UC Davis calls it "AggiePark via the AMP Park app." It replaced ParkMobile in 2023.
- UC Davis zone categories: **A, C+, C, F, L, M** (no zone numbers). A daily permit is valid in any equivalent or lower-cost zone.
- A zones are reserved for employees until 5 p.m.
- No public developer API was found. AMP is a payments system and doesn't expose occupancy.
- The AMP map shows point markers (one per zone/sign), clustered, with names like "C Zone/Visitor Parking", "South/West F Zone", "West Village Hourly Parking". There are hundreds of points; several per physical lot. See `amp_map_screenshot.png`.

## How lots.json was built
- Hand-collected by the developer from the AMP Park map, cross-referenced with Google Maps coordinates.
- ~154+ entries, covering ~70% of Davis at time of writing; cleaned into JSON.
- Record the collection date in the README; zones can change.
- Known campus structures: Gateway, Pavilion, Quad District, Hopkins Parking Facility.

## Still to do
- Confirm which zones students can use (`Config.studentZones`) against the TAPS daily rates page.
- Fill in landmark coordinates in `landmarks.json` by hand (right-click in Google Maps → copy coordinates).
