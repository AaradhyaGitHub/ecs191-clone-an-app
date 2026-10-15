import SwiftUI

/// "You're in Lot 47 / Zone C · open to C permit holders", shown at the closest zoom.
struct ZoneCard: View {
    let lot: Lot

    var body: some View {
        let zone = lot.zones.first { Config.studentZones.contains($0) } ?? lot.zones.first ?? "–"
        let colors = Theme.tagColors(for: zone)
        HStack(spacing: 12) {
            Text(zone)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(colors.fg)
                .frame(width: 40, height: 40)
                .background(colors.bg, in: RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text("You're in \(lot.name)")
                    .font(.system(.headline, weight: .bold))
                    .foregroundStyle(Theme.ink)
                Text("Zone \(zone) · open to \(zone) permit holders")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.inkSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: Theme.shadow(0.18), radius: 30, y: 10)
        .accessibilityElement(children: .combine)
    }
}
