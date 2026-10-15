import SwiftUI

/// The 1 / 2 / 3 pin on the results map. Gold and larger when selected.
struct NumberedPin: View {
    let number: Int
    let isSelected: Bool

    var body: some View {
        let size: CGFloat = isSelected ? 40 : 34
        Text("\(number)")
            .font(.system(size: isSelected ? 17 : 15, weight: .bold))
            .foregroundStyle(isSelected ? Theme.navy : Theme.pinText)
            .frame(width: size, height: size)
            .background(isSelected ? Theme.gold : Theme.pinFill, in: Circle())
            .overlay(Circle().strokeBorder(Theme.pinBorder, lineWidth: 3))
            .shadow(color: Theme.shadow(0.35), radius: 10, y: 4)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isSelected)
    }
}
