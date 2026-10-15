import SwiftUI

/// A floating card over the map for edge states: location off, far from campus,
/// or data that failed to load.
struct StateCard: View {
    struct Action {
        let title: String
        let systemImage: String
        let run: () -> Void
    }

    let systemImage: String
    let tileColor: Color
    let title: String
    let message: String
    var action: Action?

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.accentText)
                    .frame(width: 44, height: 44)
                    .background(tileColor, in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(Theme.inkBody)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            if let action {
                Button(action: action.run) {
                    HStack(spacing: 8) {
                        Image(systemName: action.systemImage)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.gold)
                        Text(action.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Theme.navy, in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(20)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: Theme.shadow(0.18), radius: 30, y: 10)
        .accessibilityElement(children: .contain)
    }
}
