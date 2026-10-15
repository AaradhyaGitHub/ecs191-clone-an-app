import SwiftUI

/// A zone letter badge such as "C" or "L".
/// `.neutral` is the navy-on-tile style on result cards; `.colored` is the
/// blue C / orange L style on map markers.
struct ZoneTag: View {
    enum Style { case neutral, colored }

    let zone: String
    var style: Style = .neutral

    var body: some View {
        let colors = style == .neutral ? (bg: Theme.tileFill, fg: Theme.tileText) : Theme.tagColors(for: zone)
        Text(zone)
            .font(.system(size: 13, weight: style == .neutral ? .bold : .heavy))
            .foregroundStyle(colors.fg)
            .padding(.horizontal, style == .neutral ? 6 : 3)
            .frame(minWidth: style == .neutral ? 24 : 22, minHeight: 22)
            .background(colors.bg, in: RoundedRectangle(cornerRadius: 6))
            .accessibilityLabel("Zone \(zone)")
    }
}
