import SwiftUI

/// Explains why location is needed before iOS shows its permission prompt.
struct LocationPrimerView: View {
    let onContinue: () -> Void
    let onSearchInstead: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var headlineSize: CGFloat = 30

    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 28) {
                PrimerIllustration()
                VStack(alignment: .leading, spacing: 12) {
                    Text("Find parking from where you are")
                        .font(.system(size: headlineSize, weight: .heavy))
                        .tracking(-0.6)
                        .foregroundStyle(Theme.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Your location is used to rank the closest student lots and get drive times from Apple Maps. Only while the app is open. Nothing is saved.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(Theme.inkBody)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxHeight: .infinity)

            Text("iOS will ask for permission next.")
                .font(.footnote)
                .foregroundStyle(Theme.inkSecondary)
                .padding(.bottom, 6)
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Theme.navy, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressableStyle())
            Button(action: onSearchInstead) {
                Text("Search a building instead")
                    .font(.headline)
                    .foregroundStyle(Theme.accentText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 8)
        .background(Theme.screen.ignoresSafeArea())
    }
}

/// The small map drawing from LocationAsk.dc.html: blocks, a park, roads,
/// the blue "you" dot and two numbered pins.
private struct PrimerIllustration: View {
    var body: some View {
        Canvas { context, _ in
            context.fill(Path(CGRect(x: 0, y: 0, width: 220, height: 160)), with: .color(Color(hex: 0xECEEE8)))
            for rect in [CGRect(x: 10, y: 10, width: 54, height: 40),
                         CGRect(x: 76, y: 10, width: 54, height: 40),
                         CGRect(x: 142, y: 10, width: 70, height: 40)] {
                context.fill(Path(roundedRect: rect, cornerRadius: 5), with: .color(Color(hex: 0xE1E4DD)))
            }
            context.fill(Path(roundedRect: CGRect(x: 120, y: 92, width: 70, height: 44), cornerRadius: 8),
                         with: .color(Color(hex: 0xCFE3C7)))

            let white = GraphicsContext.Shading.color(.white)
            var mainRoad = Path()
            mainRoad.move(to: CGPoint(x: -10, y: 66)); mainRoad.addLine(to: CGPoint(x: 230, y: 66))
            context.stroke(mainRoad, with: white, style: StrokeStyle(lineWidth: 9, lineCap: .round))

            var curve = Path()
            curve.move(to: CGPoint(x: 100, y: 66))
            curve.addCurve(to: CGPoint(x: 108, y: 170), control1: CGPoint(x: 102, y: 100), control2: CGPoint(x: 96, y: 130))
            context.stroke(curve, with: white, style: StrokeStyle(lineWidth: 6, lineCap: .round))

            var streets = Path()
            streets.move(to: CGPoint(x: 70, y: -10)); streets.addLine(to: CGPoint(x: 70, y: 66))
            streets.move(to: CGPoint(x: 136, y: -10)); streets.addLine(to: CGPoint(x: 136, y: 66))
            context.stroke(streets, with: white, style: StrokeStyle(lineWidth: 4, lineCap: .round))

            var highway = Path()
            highway.move(to: CGPoint(x: 28, y: -10))
            highway.addCurve(to: CGPoint(x: 14, y: 170), control1: CGPoint(x: 27, y: 60), control2: CGPoint(x: 24, y: 110))
            context.stroke(highway, with: .color(Color(hex: 0xF1DA95)), lineWidth: 9)
        }
        .frame(width: 220, height: 160)
        .overlay(alignment: .topLeading) {
            ZStack {
                Circle().fill(Color(red: 30 / 255, green: 123 / 255, blue: 242 / 255).opacity(0.18)).frame(width: 48, height: 48)
                Circle().fill(Color(hex: 0x1E7BF2)).frame(width: 18, height: 18)
                    .overlay(Circle().strokeBorder(.white, lineWidth: 3))
            }
            .offset(x: 52, y: 26)
        }
        .overlay(alignment: .topLeading) { pin(1, size: 30, fill: Theme.gold, text: Theme.navy).offset(x: 126, y: 78) }
        .overlay(alignment: .topLeading) { pin(2, size: 26, fill: Theme.navy, text: .white).offset(x: 168, y: 104) }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .accessibilityHidden(true)
    }

    private func pin(_ number: Int, size: CGFloat, fill: Color, text: Color) -> some View {
        Text("\(number)")
            .font(.system(size: size == 30 ? 14 : 12, weight: .bold))
            .foregroundStyle(text)
            .frame(width: size, height: size)
            .background(fill, in: Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: 3))
    }
}
