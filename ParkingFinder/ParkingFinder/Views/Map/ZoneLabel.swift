import SwiftUI

/// At the closest zoom, each lot shows one capsule label: zone letter + name.
/// The lot the user is standing in gets a blue ring and a gentle breathing glow.
struct ZoneLabel: View {
    let lot: Lot
    let isCurrent: Bool

    @State private var breathing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let zone = lot.zones.first { Config.studentZones.contains($0) } ?? lot.zones.first ?? "–"
        let colors = Theme.tagColors(for: zone)
        HStack(spacing: 6) {
            Text(zone)
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(colors.fg)
                .frame(minWidth: 20, minHeight: 20)
                .background(colors.bg, in: Capsule())
            Text(lot.name)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .frame(maxWidth: 150)
        }
        .padding(.leading, 4)
        .padding(.trailing, 9)
        .frame(height: 30)
        .background(Theme.surface, in: Capsule())
        .overlay(Capsule().strokeBorder(isCurrent ? Theme.zoneC : Theme.surface, lineWidth: 2))
        .background {
            if isCurrent {
                // Soft breathing halo marks "you are here" (2.4 s loop).
                Capsule()
                    .fill(Theme.zoneC.opacity(breathing ? 0.42 : 0.2))
                    .padding(-6)
            }
        }
        .shadow(color: Theme.shadow(0.16), radius: 8, y: 2)
        .onAppear {
            guard isCurrent, !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { breathing = true }
        }
        .accessibilityElement()
        .accessibilityLabel("\(lot.name), zone \(zone)\(isCurrent ? ", you are here" : "")")
    }
}
