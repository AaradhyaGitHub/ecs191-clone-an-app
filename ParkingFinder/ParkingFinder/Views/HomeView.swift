import SwiftUI
import MapKit

/// The one screen of the app: the map, plus whatever floats on it
/// (search bar and controls, a results sheet, an edge-state card, or the
/// location primer). Search opens full screen on top.
struct HomeView: View {
    @Environment(DataStore.self) private var store
    @Environment(LocationManager.self) private var location
    /// "apple" or "google" once the user ticks "Remember my choice".
    @AppStorage("preferredMapsApp") private var preferredMapsApp = ""

    // Map
    @State private var position: MapCameraPosition = .automatic
    @State private var level: ZoomLevel = .areas
    @State private var settledRegion: MKCoordinateRegion?
    @State private var markersByLevel: [ZoomLevel: [MapMarker]] = [:]
    @State private var hasCenteredOnUser = false

    // Screen size, read once from GeometryReader so camera math can use it.
    @State private var screen: CGSize = .zero
    @State private var safeTop: CGFloat = 0
    @State private var safeBottom: CGFloat = 0

    // Results and overlays
    @State private var results: ResultsSession?
    @State private var regionBeforeResults: MKCoordinateRegion?
    @State private var showSearch = false
    @State private var primerDismissed = false
    @State private var mapsChoiceLot: Lot?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                map
                    .ignoresSafeArea()

                if results == nil {
                    browseOverlay
                        .transition(.opacity)
                }

                if let results {
                    VStack {
                        Spacer()
                        ResultsSheet(
                            session: results,
                            height: sheetHeight(for: results),
                            bottomInset: safeBottom,
                            onSelect: select,
                            onNavigate: navigate,
                            onClose: closeResults
                        )
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                }

                if let lot = mapsChoiceLot {
                    mapsChoiceOverlay(lot)
                        .zIndex(2)
                }

                if showPrimer {
                    LocationPrimerView(
                        onContinue: {
                            primerDismissed = true
                            location.requestPermission()
                        },
                        onSearchInstead: {
                            primerDismissed = true
                            showSearch = true
                        }
                    )
                    .transition(.opacity)
                    .zIndex(3)
                }
            }
            .onAppear { updateLayout(geo) }
            .onChange(of: geo.size) { updateLayout(geo) }
        }
        .fullScreenCover(isPresented: $showSearch) {
            SearchView(
                landmarks: store.landmarks,
                userLocation: location.location?.coordinate,
                onPick: { landmark in
                    showSearch = false
                    startResults(from: .landmark(landmark))
                },
                onCancel: { showSearch = false }
            )
        }
        .onAppear {
            position = .region(store.campusRegion)
        }
        .onChange(of: location.location) {
            centerOnUserIfNeeded()
            rankIfReady()
        }
        .onChange(of: location.authorization) {
            // Permission was refused while "Finding nearby lots…" was showing.
            if location.isDenied, results?.origin == .user, results?.lots == nil {
                closeResults()
            }
        }
    }

    // MARK: - Map

    private var map: some View {
        CampusMapView(
            position: $position,
            level: level,
            markers: markersByLevel[level] ?? [],
            otherLots: store.otherLots,
            greyDotRadius: greyDotRadius,
            currentLotID: currentLot?.id,
            results: results,
            campusChip: isFarAway && level == .city ? store.campusCenter : nil,
            onLevelChange: { newLevel in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { level = newLevel }
            },
            onCameraSettled: { settledRegion = $0 },
            onTapMarker: zoomIn(on:),
            onSelectPin: select
        )
    }

    /// A grey dot is ~9 pt across at the current level, converted to meters.
    private var greyDotRadius: Double {
        guard screen.height > 0 else { return 10 }
        return 4.5 * level.span * 111_000 / screen.height
    }

    // MARK: - Home overlay (search, legend, controls, bottom card or button)

    private var browseOverlay: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                SearchBarButton { showSearch = true }
                MapLegend(showsOther: level >= .lots)
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

            ZoomControls(
                level: level,
                onZoomIn: { if let next = level.next { zoom(to: next) } },
                onZoomOut: { if let previous = level.previous { zoom(to: previous) } },
                onLocate: locateUser
            )
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16)
            // 280 pt from the top of an 844 pt screen in the design; scaled for other phones.
            .padding(.top, max(screen.height * 0.332 - safeTop, 130))

            VStack(spacing: 12) {
                Spacer()
                bottomContent
            }
            .padding(.horizontal, 16)
            .padding(.bottom, safeBottom > 0 ? 0 : 16)
        }
    }

    @ViewBuilder
    private var bottomContent: some View {
        if let error = store.loadError {
            StateCard(systemImage: "exclamationmark.triangle", tileColor: Theme.warnTile,
                      title: "Couldn't load parking data", message: error)
        } else if location.isDenied {
            StateCard(
                systemImage: "location.slash",
                tileColor: Theme.warnTile,
                title: "Location is off",
                message: "Turn it on to see the lots closest to you. Search still works: tap the bar above and pick a building.",
                action: .init(title: "Open Settings", systemImage: "gearshape", run: openSettings)
            )
        } else if isFarAway {
            StateCard(
                systemImage: "map",
                tileColor: Theme.tileFill,
                title: "You're not near UC Davis",
                message: "Nearby results only cover campus lots. Planning ahead? Pick the building you're heading to.",
                action: .init(title: "Search campus buildings", systemImage: "magnifyingglass", run: { showSearch = true })
            )
        } else {
            if level == .yourZone, let lot = currentLot {
                ZoneCard(lot: lot)
                    .transition(.asymmetric(
                        insertion: .offset(y: 24).combined(with: .opacity)
                            .animation(.spring(response: 0.52, dampingFraction: 0.7).delay(0.25)),
                        removal: .opacity
                    ))
            }
            PrimaryButton(title: "Find student parking near me", action: findParkingNearMe)
        }
    }

    // MARK: - Derived state

    private var showPrimer: Bool {
        location.authorization == .notDetermined && !primerDismissed && store.loadError == nil
    }

    private var isFarAway: Bool {
        guard let here = location.location?.coordinate else { return false }
        return Ranking.haversineMeters(here, store.campusCenter) > Config.farAwayMeters
    }

    /// The student lot the user is standing in (closest one within a few dozen meters).
    private var currentLot: Lot? {
        guard let here = location.location?.coordinate,
              let nearest = Ranking.topLots(store.studentLots, near: here, count: 1).first,
              Ranking.haversineMeters(here, nearest.coordinate) <= Config.insideLotMeters
        else { return nil }
        return nearest
    }

    private func sheetHeight(for session: ResultsSession) -> CGFloat {
        let designHeight: CGFloat = session.landmark == nil ? 567 : 620
        return min(designHeight, screen.height * 0.7)
    }

    // MARK: - Layout and camera

    private func updateLayout(_ geo: GeometryProxy) {
        safeTop = geo.safeAreaInsets.top
        safeBottom = geo.safeAreaInsets.bottom
        let full = CGSize(width: geo.size.width, height: geo.size.height + safeTop + safeBottom)
        guard full != screen else { return }
        screen = full
        // Cluster once per level for this screen size. Cheap (a few dozen lots), and
        // it means panning the map never has to re-cluster.
        markersByLevel = Dictionary(uniqueKeysWithValues: ZoomLevel.allCases.map { level in
            (level, MapClusterer.markers(for: store.studentLots, level: level, mapHeight: full.height))
        })
    }

    private func move(to center: CLLocationCoordinate2D, latitudeDelta: Double) {
        withAnimation(.smooth(duration: 0.7)) {
            position = .region(CameraMath.region(center: center, latitudeDelta: latitudeDelta, screen: screen))
        }
    }

    private func zoom(to target: ZoomLevel) {
        move(to: settledRegion?.center ?? store.campusCenter, latitudeDelta: target.span)
    }

    /// Tapping a donut or lot zooms one level in, centered on it.
    private func zoomIn(on marker: MapMarker) {
        if let next = level.next {
            move(to: marker.coordinate, latitudeDelta: next.span)
        } else {
            let current = settledRegion?.span.latitudeDelta ?? level.span
            move(to: marker.coordinate, latitudeDelta: current / 2)
        }
    }

    private func locateUser() {
        if let here = location.location?.coordinate {
            move(to: here, latitudeDelta: ZoomLevel.yourZone.span)
        } else if location.authorization == .notDetermined {
            location.requestPermission()
        } else if location.isDenied {
            openSettings()
        }
    }

    /// The first time we learn where the user is, glide the map to them
    /// (or, if they're far away, show both them and campus).
    private func centerOnUserIfNeeded() {
        guard !hasCenteredOnUser, results == nil, let here = location.location?.coordinate else { return }
        hasCenteredOnUser = true
        if isFarAway {
            if let region = CameraMath.fit([here, store.campusCenter], screen: screen, topInset: 130, bottomCover: 220) {
                withAnimation(.smooth(duration: 0.9)) { position = .region(region) }
            }
        } else {
            move(to: here, latitudeDelta: ZoomLevel.areas.span)
        }
    }

    // MARK: - Results

    private func findParkingNearMe() {
        if location.authorization == .notDetermined {
            location.requestPermission()
        }
        startResults(from: .user)
    }

    private func startResults(from origin: ResultsSession.Origin) {
        if results == nil { regionBeforeResults = settledRegion }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            results = ResultsSession(origin: origin)
        }
        rankIfReady()
    }

    /// Ranks as soon as the origin is known. For "near me" that may mean waiting
    /// for the first location fix; the sheet shows "Finding nearby lots…" meanwhile.
    private func rankIfReady() {
        guard var session = results, session.lots == nil else { return }
        let origin: CLLocationCoordinate2D
        switch session.origin {
        case .user:
            guard let here = location.location?.coordinate else { return }
            origin = here
        case .landmark(let landmark):
            guard let place = landmark.coordinate else { return }
            origin = place
        }

        let lots = Ranking.topLots(store.studentLots, near: origin, count: Config.resultCount)
        session.lots = lots
        session.driveTimes = Dictionary(uniqueKeysWithValues: lots.map { ($0.id, DriveTime.loading) })
        withAnimation(.smooth(duration: 0.35)) { results = session }

        let topInset = safeTop + 16
        if let region = CameraMath.fit([origin] + lots.map(\.coordinate), screen: screen,
                                       topInset: topInset, bottomCover: sheetHeight(for: session)) {
            withAnimation(.smooth(duration: 0.8)) { position = .region(region) }
        }
        fetchDriveTimes(for: lots, sessionID: session.id)
    }

    /// One ETA request per lot, all at once. Each card fills in as its answer
    /// arrives; the cards never wait for ETAs.
    private func fetchDriveTimes(for lots: [Lot], sessionID: UUID) {
        for lot in lots {
            Task {
                let seconds = location.isAuthorized ? await DriveTimeService.driveTime(to: lot.coordinate) : nil
                // Ignore late answers for a search the user already closed.
                guard results?.id == sessionID else { return }
                let value: DriveTime
                if let seconds {
                    value = .minutes(Formatters.minutes(seconds))
                } else if let here = location.location?.coordinate {
                    value = .straightLine(meters: Ranking.haversineMeters(here, lot.coordinate))
                } else {
                    value = .unavailable
                }
                results?.driveTimes[lot.id] = value
            }
        }
    }

    private func select(_ index: Int) {
        guard results?.selectedIndex != index else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            results?.selectedIndex = index
        }
    }

    private func closeResults() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            results = nil
            mapsChoiceLot = nil
        }
        if let region = regionBeforeResults {
            withAnimation(.smooth(duration: 0.7)) { position = .region(region) }
        }
    }

    // MARK: - Navigation hand-off

    private func navigate(to lot: Lot) {
        let hasGoogle = Navigator.isGoogleMapsInstalled
        if let saved = MapsApp(rawValue: preferredMapsApp), saved == .apple || hasGoogle {
            Navigator.directions(to: lot, using: saved)
        } else if hasGoogle {
            withAnimation(.easeOut(duration: 0.2)) { mapsChoiceLot = lot }
        } else {
            Navigator.directions(to: lot, using: .apple)
        }
    }

    private func mapsChoiceOverlay(_ lot: Lot) -> some View {
        ZStack(alignment: .bottom) {
            Theme.dim
                .ignoresSafeArea()
                .onTapGesture { dismissMapsChoice() }
                .transition(.opacity)
            MapsChoiceSheet(
                lot: lot,
                onChoose: { app, remember in
                    if remember { preferredMapsApp = app.rawValue }
                    dismissMapsChoice()
                    Navigator.directions(to: lot, using: app)
                },
                onCancel: dismissMapsChoice
            )
            .padding(.bottom, safeBottom > 0 ? 0 : 10)
            .transition(.move(edge: .bottom))
        }
    }

    private func dismissMapsChoice() {
        withAnimation(.easeOut(duration: 0.2)) { mapsChoiceLot = nil }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
