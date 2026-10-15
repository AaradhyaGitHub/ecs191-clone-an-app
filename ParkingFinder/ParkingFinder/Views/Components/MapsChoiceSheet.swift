import SwiftUI

/// iOS-style action sheet: "Directions to {lot}" → Apple Maps / Google Maps.
/// Only shown when Google Maps is installed.
struct MapsChoiceSheet: View {
    let lot: Lot
    let onChoose: (MapsApp, _ remember: Bool) -> Void
    let onCancel: () -> Void

    @State private var remember = false

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("Directions to \(lot.name)")
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("Driving, from your current location")
                        .font(.footnote)
                        .foregroundStyle(Theme.inkSecondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 14)

                row("Apple Maps", systemImage: "map") { onChoose(.apple, remember) }
                row("Google Maps", systemImage: "mappin.and.ellipse") { onChoose(.google, remember) }

                Divider().overlay(Theme.hairline)
                Button {
                    remember.toggle()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: remember ? "checkmark.square.fill" : "square")
                            .font(.system(size: 18))
                            .foregroundStyle(remember ? Theme.accentText : Theme.inkSecondary)
                        Text("Remember my choice")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.inkSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(remember ? .isSelected : [])
            }
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Theme.accentText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, 10)
    }

    private func row(_ title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Divider().overlay(Theme.hairline)
            Button(action: action) {
                HStack(spacing: 10) {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .medium))
                    Text(title)
                        .font(.system(size: 19, weight: .medium))
                }
                .foregroundStyle(Theme.accentText)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
