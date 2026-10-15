import SwiftUI

/// The fixed-height bottom sheet with the 3 closest lots (or the loading state).
/// A custom overlay instead of `.sheet` so the map behind stays fully interactive.
struct ResultsSheet: View {
    let session: ResultsSession
    let height: CGFloat
    let bottomInset: CGFloat
    let onSelect: (Int) -> Void
    let onNavigate: (Lot) -> Void
    let onClose: () -> Void

    /// How far the sheet is being dragged down (drag down to dismiss).
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Theme.grabber)
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .accessibilityHidden(true)
            header
            ScrollView(showsIndicators: false) {
                content
                    .padding(.bottom, max(bottomInset, 16))
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: height, alignment: .top)
        .background(
            Theme.sheet,
            in: UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24, style: .continuous)
        )
        .shadow(color: Theme.shadow(0.12), radius: 30, y: -8)
        .offset(y: dragOffset)
        .gesture(dismissDrag)
        .sensoryFeedback(.selection, trigger: session.selectedIndex)
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 12) {
            if session.lots == nil { ArcSpinner() }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.title3, weight: .bold))
                    .tracking(-0.2)
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Theme.inkSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.closeIcon)
                    .frame(width: 44, height: 44)
                    .background(Theme.chipFill, in: Circle())
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Close")
        }
        .frame(minHeight: 48)
    }

    @ViewBuilder
    private var content: some View {
        if let lots = session.lots {
            if lots.isEmpty {
                emptyState
            } else {
                VStack(spacing: session.landmark == nil ? 10 : 8) {
                    ForEach(Array(lots.enumerated()), id: \.element.id) { index, lot in
                        LotCard(
                            number: index + 1,
                            lot: lot,
                            driveTime: session.driveTimes[lot.id] ?? .loading,
                            isSelected: index == session.selectedIndex,
                            walkLine: walkLine(for: lot),
                            onSelect: { onSelect(index) },
                            onNavigate: { onNavigate(lot) }
                        )
                        .transition(.opacity.combined(with: .offset(y: 12)))
                    }
                }
            }
        } else {
            VStack(spacing: 10) {
                SkeletonCard(nameWidth: 150, tagWidth: 58)
                SkeletonCard(nameWidth: 110, tagWidth: 30)
                SkeletonCard(nameWidth: 130, tagWidth: 58)
            }
            .transition(.opacity)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No student lots found")
                .font(.system(.title3, weight: .bold))
                .foregroundStyle(Theme.ink)
            Text("There are no lots for your zones in the parking data yet.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    // MARK: - Text

    private var title: String {
        if session.lots == nil { return "Finding nearby lots…" }
        if let landmark = session.landmark { return "Parking near \(landmark.name)" }
        return "Student parking near you"
    }

    private var subtitle: String {
        if session.lots == nil { return "Checking drive times for leaving in 10 min" }
        if let landmark = session.landmark { return "Closest to \(landmark.name) · drive times if you leave in 10 min" }
        return "Drive times if you leave in 10 min"
    }

    private func walkLine(for lot: Lot) -> String? {
        guard let landmark = session.landmark, let place = landmark.coordinate else { return nil }
        let meters = Ranking.haversineMeters(lot.coordinate, place)
        return Formatters.walkLine(meters: meters, to: landmark.displayShortName)
    }

    // MARK: - Drag to dismiss

    private var dismissDrag: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                // Follow the finger downward; resist upward drags.
                dragOffset = value.translation.height > 0 ? value.translation.height : value.translation.height / 6
            }
            .onEnded { value in
                if value.translation.height > 120 || value.predictedEndTranslation.height > 260 {
                    onClose()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { dragOffset = 0 }
                }
            }
    }
}
