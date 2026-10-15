import SwiftUI

/// One result: number badge, lot name, zone tags, drive time, and Navigate.
struct LotCard: View {
    let number: Int
    let lot: Lot
    let driveTime: DriveTime
    let isSelected: Bool
    /// Only in landmark mode, e.g. "About 4 min walk (320 m) to Olson".
    let walkLine: String?
    let onSelect: () -> Void
    let onNavigate: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: walkLine == nil ? 12 : 10) {
            Button(action: onSelect) {
                VStack(alignment: .leading, spacing: 10) {
                    summaryRow
                    if let walkLine { walkRow(walkLine) }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilitySummary)
            .accessibilityAddTraits(isSelected ? .isSelected : [])

            navigateButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, walkLine == nil ? 14 : 12)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(isSelected ? Theme.gold : Theme.surface, lineWidth: 2)
        )
        .shadow(color: Theme.shadow(0.06), radius: 8, y: 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
    }

    private var summaryRow: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isSelected ? Theme.navy : Theme.pinText)
                .frame(width: 32, height: 32)
                .background(isSelected ? Theme.gold : Theme.pinFill, in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(lot.name)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    ForEach(lot.zones, id: \.self) { ZoneTag(zone: $0) }
                    if let area = lot.area {
                        Text(area)
                            .font(.footnote)
                            .foregroundStyle(Theme.inkSecondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 0) {
                Text(timeText)
                    .font(.system(.title2, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(Theme.ink)
                    .contentTransition(.numericText())
                Text(timeCaption)
                    .font(.caption)
                    .foregroundStyle(Theme.inkSecondary)
            }
            .animation(.smooth, value: driveTime)
        }
        .frame(minHeight: 52)
    }

    private func walkRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "figure.walk")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.accentText)
            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(Theme.inkBody)
        }
        .padding(.leading, 44)
    }

    private var navigateButton: some View {
        // Dark mode: the selected card's button turns gold (ResultsDark.dc.html).
        let goldStyle = colorScheme == .dark && isSelected
        return Button(action: onNavigate) {
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(goldStyle ? Theme.navy : Theme.gold)
                Text("Navigate")
                    .font(.system(.callout, weight: .semibold))
                    .foregroundStyle(goldStyle ? Theme.navy : Theme.navigateText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: walkLine == nil ? 46 : 44)
            .background(goldStyle ? Theme.gold : Theme.navigateFill, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Navigate to \(lot.name)")
    }

    private var timeText: String {
        switch driveTime {
        case .loading: "…"
        case .minutes(let minutes): "\(minutes) min"
        case .straightLine(let meters): Formatters.miles(meters)
        case .unavailable: "–"
        }
    }

    private var timeCaption: String {
        if case .straightLine = driveTime { return "straight-line" }
        return "drive"
    }

    private var accessibilitySummary: String {
        let time: String
        switch driveTime {
        case .loading: time = "drive time loading"
        case .minutes(let minutes): time = "\(minutes) minute drive"
        case .straightLine(let meters): time = "\(Formatters.miles(meters)) away in a straight line"
        case .unavailable: time = "drive time unavailable"
        }
        return "\(number). \(lot.name), zone \(lot.zones.joined(separator: " and ")), \(time)\(walkLine.map { ". \($0)" } ?? "")"
    }
}
