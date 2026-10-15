import SwiftUI
import MapKit

/// The full-screen map. It only draws; HomeView owns the state and decides
/// what to show.
///
/// Smoothness notes:
/// - Markers arrive pre-clustered per zoom level, so panning never re-clusters.
/// - The continuous camera callback only reports a *level* change, so the view
///   isn't rebuilt on every frame of a pinch.
/// - Non-student lots are MapKit circles (drawn by MapKit, not SwiftUI views).
struct CampusMapView: View {
    @Binding var position: MapCameraPosition
    let level: ZoomLevel
    let markers: [MapMarker]
    let otherLots: [Lot]
    let greyDotRadius: Double
    let currentLotID: String?
    let results: ResultsSession?
    /// Where to put the "UC Davis" chip when the user is far away (nil hides it).
    let campusChip: CLLocationCoordinate2D?
    let onLevelChange: (ZoomLevel) -> Void
    let onCameraSettled: (MKCoordinateRegion) -> Void
    let onTapMarker: (MapMarker) -> Void
    let onSelectPin: (Int) -> Void

    var body: some View {
        Map(position: $position, interactionModes: [.pan, .zoom]) {
            UserAnnotation { _ in UserDot() }

            if let results {
                resultsContent(results)
            } else {
                browseContent
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControls { }
        .onMapCameraChange(frequency: .continuous) { context in
            let newLevel = ZoomLevel(latitudeDelta: context.region.span.latitudeDelta)
            if newLevel != level { onLevelChange(newLevel) }
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            onCameraSettled(context.region)
        }
    }

    // MARK: - Home map (zoom system)

    @MapContentBuilder
    private var browseContent: some MapContent {
        if let campusChip {
            // Far away: campus is a single "UC Davis" chip instead of donuts (FarAway.dc.html).
            Annotation("UC Davis", coordinate: campusChip) {
                PlaceMarker(name: "UC Davis", squareSize: 20, showsIcon: false)
            }
            .annotationTitles(.hidden)
        } else {
            zoomSystemContent
        }
    }

    @MapContentBuilder
    private var zoomSystemContent: some MapContent {
        if level >= .lots {
            ForEach(otherLots) { lot in
                MapCircle(center: lot.coordinate, radius: greyDotRadius)
                    .foregroundStyle(Theme.greyDot)
                    .stroke(.white, lineWidth: 2)
            }
        }

        ForEach(Array(markers.enumerated()), id: \.element.id) { index, marker in
            Annotation(title(of: marker), coordinate: marker.coordinate, anchor: anchor(of: marker)) {
                Button { onTapMarker(marker) } label: {
                    markerView(marker, index: index)
                }
                .buttonStyle(.plain)
            }
            .annotationTitles(.hidden)
        }
    }

    @ViewBuilder
    private func markerView(_ marker: MapMarker, index: Int) -> some View {
        // Stagger by ~50 ms per marker, capped so big sets don't trickle in slowly.
        let delay = 0.14 + Double(min(index, 8)) * 0.05
        switch marker.kind {
        case .cluster(let cluster):
            DonutMarker(cluster: cluster, ringDelay: delay + 0.25)
                .popIn(delay: delay)
        case .lot(let lot):
            if level == .yourZone {
                ZoneLabel(lot: lot, isCurrent: lot.id == currentLotID)
                    .popIn(delay: delay)
            } else {
                LotMarker(lot: lot, showsName: level == .lotsAndZones)
                    .popIn(delay: delay)
            }
        }
    }

    private func anchor(of marker: MapMarker) -> UnitPoint {
        if case .lot = marker.kind, level != .yourZone { return .bottom }
        return .center
    }

    private func title(of marker: MapMarker) -> String {
        switch marker.kind {
        case .cluster(let cluster): cluster.name ?? "\(cluster.count) lots"
        case .lot(let lot): lot.name
        }
    }

    // MARK: - Results map

    @MapContentBuilder
    private func resultsContent(_ results: ResultsSession) -> some MapContent {
        if let landmark = results.landmark, let coordinate = landmark.coordinate {
            Annotation(landmark.name, coordinate: coordinate) {
                PlaceMarker(name: landmark.name)
            }
            .annotationTitles(.hidden)
        }

        if let lots = results.lots {
            ForEach(Array(lots.enumerated()), id: \.element.id) { index, lot in
                Annotation(lot.name, coordinate: lot.coordinate) {
                    Button { onSelectPin(index) } label: {
                        NumberedPin(number: index + 1, isSelected: index == results.selectedIndex)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(index + 1). \(lot.name)")
                    .popIn(delay: 0.1 + Double(index) * 0.06)
                }
                .annotationTitles(.hidden)
            }
        }
    }
}
