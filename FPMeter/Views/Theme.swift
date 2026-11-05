//
//  Theme.swift
//  FPMeter
//

import SwiftUI

enum Theme {

    // MARK: - Core colors
    static let bg         = Color(hex: "#F8F9FA")
    static let surface    = Color.white
    static let surfaceAlt = Color(hex: "#F1F3F5")

    static let primary      = Color(hex: "#1E3A5F")
    static let primaryLight = Color(hex: "#2C5282")
    static let accent       = Color(hex: "#3182CE")

    // MARK: - Complexity
    static let low     = Color(hex: "#2E7D32")
    static let average = Color(hex: "#E65100")
    static let high    = Color(hex: "#C62828")

    static func complexityColor(_ level: ComplexityLevel) -> Color {
        switch level {
        case .low: return low
        case .average: return average
        case .high: return high
        }
    }

    // MARK: - Transaction type
    static func typeColor(_ type: TransactionType) -> Color {
        switch type {
        case .ilf: return Color(hex: "#1565C0")
        case .eif: return Color(hex: "#6A1B9A")
        case .ei:  return Color(hex: "#00695C")
        case .eo:  return Color(hex: "#E65100")
        case .eq:  return Color(hex: "#4527A0")
        }
    }

    // MARK: - Text
    static let text      = Color(hex: "#1A202C")
    static let textMuted = Color(hex: "#718096")
    static let textLight = Color(hex: "#A0AEC0")

    // MARK: - Borders
    static let border     = Color(hex: "#E2E8F0")
    static let borderDark = Color(hex: "#CBD5E0")

    // MARK: - Status
    static let success = Color(hex: "#38A169")
    static let warning = Color(hex: "#D69E2E")
    static let danger  = Color(hex: "#E53E3E")
}

extension Color {
    init(hex: String) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8)  & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
