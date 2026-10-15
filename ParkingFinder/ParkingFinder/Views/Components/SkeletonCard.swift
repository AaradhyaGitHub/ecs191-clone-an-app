import SwiftUI

/// Gray placeholder card shown while results load. Pulses softly.
struct SkeletonCard: View {
    let nameWidth: CGFloat
    let tagWidth: CGFloat

    @State private var bright = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Circle().fill(Theme.skeleton).frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 6).fill(Theme.skeleton).frame(width: nameWidth, height: 16)
                    RoundedRectangle(cornerRadius: 6).fill(Theme.skeletonSoft).frame(width: tagWidth, height: 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                RoundedRectangle(cornerRadius: 8).fill(Theme.skeleton).frame(width: 52, height: 30)
            }
            RoundedRectangle(cornerRadius: 12).fill(Theme.skeletonSoft).frame(height: 46)
        }
        .padding(16)
        .frame(height: 142)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 18))
        .opacity(bright ? 1 : 0.55)
        .onAppear {
            guard !reduceMotion else { bright = true; return }
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) { bright = true }
        }
        .accessibilityHidden(true)
    }
}

/// The navy arc spinner from Loading.dc.html.
struct ArcSpinner: View {
    @State private var spinning = false

    var body: some View {
        ZStack {
            Circle().stroke(Theme.skeleton, lineWidth: 3)
            Circle()
                .trim(from: 0, to: 0.25)
                .stroke(Theme.accentText, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(spinning ? 360 : 0))
        }
        .frame(width: 18, height: 18)
        .padding(3)
        .onAppear {
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) { spinning = true }
        }
        .accessibilityHidden(true)
    }
}
