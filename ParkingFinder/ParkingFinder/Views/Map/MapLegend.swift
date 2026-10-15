import SwiftUI

/// "■ C commuter  ■ L resident", plus "⬚ not for students" once lots are visible.
struct MapLegend: View {
    let showsOther: Bool

    var body: some View {
        HStack(spacing: 12) {
            item(color: Theme.zoneC, text: "C commuter")
            item(color: Theme.zoneL, text: "L resident")
            if showsOther {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Theme.zoneOther, style: StrokeStyle(lineWidth: 1.5, dash: [2, 1.5]))
                        .frame(width: 9, height: 9)
                    Text("not for students")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.inkSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .lineLimit(1)
        .padding(.horizontal, 12)
        .frame(height: 32)
        .background(Theme.surface.opacity(0.95), in: Capsule())
        .shadow(color: Theme.shadow(0.10), radius: 8, y: 2)
        .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.42), value: showsOther)
        .accessibilityElement(children: .combine)
    }

    private func item(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 10, height: 10)
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.inkBody)
        }
    }
}
