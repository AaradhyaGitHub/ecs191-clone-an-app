import SwiftUI

/// The area / cluster marker: a navy circle with the lot count, ringed by a
/// blue arc (share of C lots) and an orange arc (share of L lots).
struct DonutMarker: View {
    let cluster: MapMarker.Cluster
    /// Delay before the rings draw in (the marker itself pops in first).
    let ringDelay: Double

    @State private var ringProgress: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var count: Int { cluster.count }

    /// Ring radius grows with the number of lots.
    private var radius: CGFloat {
        count >= 40 ? 34 : count >= 20 ? 30 : count >= 8 ? 24 : 21
    }

    var body: some View {
        let size = radius * 2 + 12
        ZStack {
            Circle().fill(Theme.surface)                       // white halo
            rings
            Circle().fill(Theme.navy).padding(11)              // inner circle, radius r − 5
            Text("\(count)")
                .font(.system(size: count >= 20 ? 20 : 16, weight: .heavy))
                .tracking(-0.4)
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .shadow(color: Theme.shadow(0.28), radius: 10, y: 4)
        // The name hangs below as an overlay so the map anchors on the circle's center.
        .overlay(alignment: .top) {
            if let name = cluster.name {
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .shadow(color: Theme.surface, radius: 1.5)
                    .shadow(color: Theme.surface, radius: 3)
                    .fixedSize()
                    .offset(y: size + 4)
            }
        }
        .onAppear {
            if reduceMotion {
                ringProgress = 1
            } else {
                withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.8).delay(ringDelay)) { ringProgress = 1 }
            }
        }
        .accessibilityElement()
        .accessibilityLabel("\(cluster.name.map { "\($0), " } ?? "")\(count) student lots: \(cluster.cCount) zone C, \(cluster.lCount) zone L. Zoom in.")
    }

    /// Two trimmed circle strokes, rotated so they start at 12 o'clock.
    private var rings: some View {
        let c = Double(cluster.cCount), l = Double(cluster.lCount)
        let total = max(c + l, 1)
        let cShare = c / total, lShare = l / total
        // A 3 pt gap between the arcs, but only when both colors are present.
        let gap = (c > 0 && l > 0) ? 3 / (2 * .pi * Double(radius)) : 0
        return ZStack {
            if c > 0 {
                Circle()
                    .trim(from: 0, to: max(cShare - gap, 0) * ringProgress)
                    .stroke(Theme.zoneC, lineWidth: 5)
            }
            if l > 0 {
                Circle()
                    .trim(from: cShare, to: cShare + max(lShare - gap, 0) * ringProgress)
                    .stroke(Theme.zoneL, lineWidth: 5)
            }
        }
        .rotationEffect(.degrees(-90))
        .padding(6)                                            // ring radius r inside the r + 6 halo
    }
}
