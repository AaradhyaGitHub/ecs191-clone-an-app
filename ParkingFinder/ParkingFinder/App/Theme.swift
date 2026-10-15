import SwiftUI
import UIKit

/// Design tokens from design/DESIGN_SPEC.md §1. Each color has a light and a dark value.
enum Theme {
    // Brand
    static let navy = Color(hex: 0x022851)
    static let gold = Color(hex: 0xFFBF00)

    // Text
    static let ink = Color(light: 0x0E1726, dark: 0xF2F4F7)
    static let inkSecondary = Color(light: 0x4A5565, dark: 0xA7B0BE)
    static let inkBody = Color(light: 0x2B3442, dark: 0xC9D0DA)
    static let placeholder = Color(light: 0x5A6472, dark: 0x8C96A5)
    /// Navy in light mode; navy is unreadable on dark surfaces, so gold in dark mode.
    static let accentText = Color(light: 0x022851, dark: 0xFFBF00)
    /// Big headline on the location primer.
    static let headline = Color(light: 0x022851, dark: 0xF2F4F7)

    // Surfaces
    static let surface = Color(light: 0xFFFFFF, dark: 0x1A1F28)
    static let sheet = Color(light: 0xF4F5F7, dark: 0x0B0F15)
    static let screen = Color(light: 0xFFFFFF, dark: 0x0B0F15)
    static let hairline = Color(light: 0xE3E6EA, dark: 0x2A3240)
    static let chipFill = Color(light: 0xE4E7EC, dark: 0x232A35)
    static let tileFill = Color(light: 0xE7ECF4, dark: 0x26324A)
    static let tileText = Color(light: 0x022851, dark: 0xD3DEF2)
    static let skeleton = Color(light: 0xE6E9EE, dark: 0x2A3240)
    static let skeletonSoft = Color(light: 0xEEF0F3, dark: 0x232A35)
    static let grabber = Color(light: 0xC9CED6, dark: 0x3A4352)
    static let fieldFill = Color(light: 0xF1F3F6, dark: 0x1A1F28)
    static let warnTile = Color(light: 0xFFF1C2, dark: 0x3A3016)
    static let closeIcon = Color(light: 0x2B3442, dark: 0xE6EAF0)
    static let clearIcon = Color(hex: 0x8A94A3)
    static let levelDotIdle = Color(light: 0xC5CBD4, dark: 0x3A4352)
    static let dim = Color(red: 5 / 255, green: 14 / 255, blue: 30 / 255).opacity(0.45)

    // Map
    static let userBlue = Color(light: 0x1E7BF2, dark: 0x3B8CFF)
    static let zoneC = Color(light: 0x2563D9, dark: 0x5B93F0)
    static let zoneCTagBg = Color(light: 0xDCE7FB, dark: 0x26324A)
    static let zoneCTagFg = Color(light: 0x1A4FB5, dark: 0xD3DEF2)
    static let zoneL = Color(light: 0xE07A1A, dark: 0xE89A4F)
    static let zoneLStroke = Color(light: 0xC4650E, dark: 0xE89A4F)
    static let zoneLTagBg = Color(light: 0xFCE6CF, dark: 0x4A3218)
    static let zoneLTagFg = Color(light: 0x8A4300, dark: 0xFCE6CF)
    static let zoneOther = Color(light: 0x8C95A3, dark: 0x6B7380)
    static let otherTagBg = Color(light: 0xE6E8EC, dark: 0x2A3240)
    static let otherTagFg = Color(light: 0x4A5565, dark: 0xA7B0BE)
    static let greyDot = Color(light: 0x9AA3AF, dark: 0x6B7380)

    // Numbered pins and card badges (dark mode swaps navy for a light tile).
    static let pinFill = Color(light: 0x022851, dark: 0xE7ECF4)
    static let pinText = Color(light: 0xFFFFFF, dark: 0x022851)
    static let pinBorder = Color(light: 0xFFFFFF, dark: 0x12171E)

    // Navigate button: light mode is always navy; dark mode is gold when selected.
    static let navigateFill = Color(light: 0x022851, dark: 0x2A3344)
    static let navigateText = Color(light: 0xFFFFFF, dark: 0xF2F4F7)

    /// Navy-tinted shadow in light mode; almost none in dark mode (spec §1).
    static func shadow(_ opacity: Double) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(opacity * 0.6)
                : UIColor(hex: 0x022851).withAlphaComponent(opacity)
        })
    }

    /// Text color for a zone letter tag, e.g. the blue "C" or orange "L".
    static func tagColors(for zone: String) -> (bg: Color, fg: Color) {
        switch zone {
        case "C": return (zoneCTagBg, zoneCTagFg)
        case "L": return (zoneLTagBg, zoneLTagFg)
        default: return (otherTagBg, otherTagFg)
        }
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(UIColor(hex: hex))
    }

    /// A color that switches automatically between light and dark mode.
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}
