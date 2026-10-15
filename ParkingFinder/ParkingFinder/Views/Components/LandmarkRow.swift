import SwiftUI

/// One campus building in the search list: icon tile, name, subtitle, distance.
struct LandmarkRow: View {
    let match: LandmarkSearch.Match
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: "building.2")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Theme.accentText)
                    .frame(width: 40, height: 40)
                    .background(Theme.tileFill, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(match.landmark.name)
                        .font(.headline)
                        .foregroundStyle(Theme.ink)
                    if let subtitle {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if let meters = match.meters {
                    Text(Formatters.miles(meters))
                        .font(.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .frame(minHeight: 64)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowPressStyle())
    }

    /// Alias match wins ("Matches “MU”"); otherwise the landmark's own subtitle.
    private var subtitle: String? {
        if let alias = match.matchedAlias { return "Matches “\(alias)”" }
        return match.landmark.subtitle
    }
}

/// A light highlight while a row is pressed, like a native list.
private struct RowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.tileFill.opacity(configuration.isPressed ? 0.6 : 0))
                    .padding(.horizontal, -8)
            )
    }
}
