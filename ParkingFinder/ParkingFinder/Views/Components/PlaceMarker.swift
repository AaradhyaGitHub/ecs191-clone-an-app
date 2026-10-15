import SwiftUI

/// A navy square with a name chip beside it. Used for the chosen landmark on
/// the results map and for "UC Davis" when the user is far away.
/// The chip is an overlay, so the map anchors on the square's center.
struct PlaceMarker: View {
    let name: String
    var squareSize: CGFloat = 28
    var showsIcon = true

    var body: some View {
        RoundedRectangle(cornerRadius: squareSize * 0.29)
            .fill(Theme.navy)
            .overlay {
                if showsIcon {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: squareSize * 0.29).strokeBorder(.white, lineWidth: 2))
            .frame(width: squareSize, height: squareSize)
            .shadow(color: Theme.shadow(0.35), radius: 8, y: 3)
            .overlay(alignment: .leading) {
                Text(name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Theme.accentText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 8))
                    .shadow(color: Theme.shadow(0.18), radius: 6, y: 2)
                    .fixedSize()
                    .offset(x: squareSize + 6)
            }
            .accessibilityElement()
            .accessibilityLabel(name)
    }
}
