import SwiftUI

/// A single lot on the map: a white tag holder with a pointer tail.
/// At "Lots + zones" the lot name slides open beside the tags.
struct LotMarker: View {
    let lot: Lot
    let showsName: Bool

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 3) {
                ForEach(lot.zones, id: \.self) { ZoneTag(zone: $0, style: .colored) }
            }
            if showsName {
                Text(lot.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .frame(maxWidth: 120, alignment: .leading)
                    .padding(.leading, 6)
                    .padding(.trailing, 3)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .padding(.horizontal, 5)
        .frame(height: 32)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 10))
        .background(alignment: .bottom) {
            // Pointer tail: a small rotated square peeking out under the marker.
            RoundedRectangle(cornerRadius: 2)
                .fill(Theme.surface)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(45))
                .offset(y: 5)
        }
        .compositingGroup()
        .shadow(color: Theme.shadow(0.22), radius: 10, y: 3)
        .padding(.bottom, 6)                                   // the map anchors at the tail tip
        .animation(.spring(response: 0.48, dampingFraction: 0.8), value: showsName)
        .accessibilityElement()
        .accessibilityLabel("\(lot.name), zone \(lot.zones.joined(separator: " and ")). Zoom in.")
    }
}
