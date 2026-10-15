import SwiftUI

/// Right-edge controls: + / − with a 6-dot level indicator between them, a
/// navy label naming the current level, and a "locate me" button below.
struct ZoomControls: View {
    let level: ZoomLevel
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void
    let onLocate: () -> Void

    private let dotRow: CGFloat = 18

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 0) {
                controlButton("plus", label: "Zoom in", action: onZoomIn)
                    .disabled(level == .yourZone)
                VStack(spacing: 0) {
                    // Top dot = closest level, so iterate from 5 down to 0.
                    ForEach(ZoomLevel.allCases.reversed(), id: \.self) { dotLevel in
                        Capsule()
                            .fill(dotLevel == level ? Theme.gold : Theme.levelDotIdle)
                            .frame(width: 6, height: dotLevel == level ? 16 : 6)
                            .frame(height: dotRow)
                    }
                }
                .padding(.vertical, 4)
                .accessibilityHidden(true)
                controlButton("minus", label: "Zoom out", action: onZoomOut)
                    .disabled(level == .city)
            }
            .frame(width: 48)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: Theme.shadow(0.14), radius: 16, y: 4)
            .overlay(alignment: .topTrailing) { levelLabel }

            Button(action: onLocate) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.userBlue)
                    .frame(width: 48, height: 48)
                    .background(Theme.surface, in: Circle())
                    .shadow(color: Theme.shadow(0.14), radius: 16, y: 4)
            }
            .buttonStyle(PressableStyle())
            .accessibilityLabel("Zoom to my location")
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.62), value: level)
    }

    /// Sits to the left of the current dot and slides with it.
    private var levelLabel: some View {
        let index = CGFloat(ZoomLevel.yourZone.rawValue - level.rawValue)
        let dotCenter = 44 + 4 + index * dotRow + dotRow / 2
        return Text(level.name)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 9)
            .frame(height: 22)
            .background(Theme.navy, in: Capsule())
            .fixedSize()
            .offset(x: -56, y: dotCenter - 11)
            .accessibilityLabel("Zoom level: \(level.name)")
    }

    private func controlButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Theme.accentText)
                .frame(width: 48, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(label)
    }
}
