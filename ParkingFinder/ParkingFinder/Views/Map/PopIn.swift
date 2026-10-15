import SwiftUI

/// Markers spring in from 40% size when they appear, staggered by `delay`.
/// Skipped entirely when Reduce Motion is on.
struct PopIn: ViewModifier {
    let delay: Double
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(shown ? 1 : 0.4)
            .opacity(shown ? 1 : 0)
            .onAppear {
                if reduceMotion {
                    shown = true
                } else {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.65).delay(delay)) { shown = true }
                }
            }
    }
}

extension View {
    func popIn(delay: Double) -> some View { modifier(PopIn(delay: delay)) }
}
