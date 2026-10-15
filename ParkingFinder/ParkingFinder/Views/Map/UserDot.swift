import SwiftUI

/// The "you are here" marker: a blue dot with a white ring and a soft halo
/// that pulses (2.2 s loop, DESIGN_SPEC.md). Drawn by us instead of MapKit's
/// default because the default takes the app's navy tint and looks like a lot marker.
struct UserDot: View {
    @State private var pulsing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.userBlue.opacity(0.22))
                .frame(width: 44, height: 44)
                .scaleEffect(pulsing ? 1 : 0.55)
                .opacity(pulsing ? 0 : 1)
            Circle()
                .fill(Theme.userBlue)
                .frame(width: 18, height: 18)
                .overlay(Circle().strokeBorder(.white, lineWidth: 3))
                .shadow(color: Theme.shadow(0.25), radius: 3, y: 1)
        }
        .onAppear {
            // Reduce Motion: keep the small static halo, no pulse.
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 2.2).repeatForever(autoreverses: false)) { pulsing = true }
        }
        .accessibilityLabel("Your location")
    }
}
