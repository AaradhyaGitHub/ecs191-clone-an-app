import SwiftUI

/// The big navy "Find student parking near me" button.
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.gold)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Theme.navy, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: Theme.shadow(0.28), radius: 24, y: 8)
        }
        .buttonStyle(PressableStyle())
    }
}

/// Shrinks a button slightly while it's pressed, so taps feel physical.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
