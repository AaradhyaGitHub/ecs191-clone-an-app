import SwiftUI

/// The white capsule at the top of the home map. It only looks like a field;
/// tapping it opens the full-screen search.
struct SearchBarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.accentText)
                Text("Search UC Davis buildings…")
                    .font(.body)
                    .foregroundStyle(Theme.placeholder)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .frame(height: 52)
            .background(Theme.surface, in: Capsule())
            .shadow(color: Theme.shadow(0.08), radius: 3, y: 1)
            .shadow(color: Theme.shadow(0.12), radius: 16, y: 4)
        }
        .buttonStyle(PressableStyle())
        .accessibilityLabel("Search UC Davis buildings")
    }
}
