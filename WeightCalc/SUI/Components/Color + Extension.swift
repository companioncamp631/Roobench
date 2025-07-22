//
//  Color + Extension.swift
//  WeightCalc
//
//  Created by D K on 20.07.2025.
//


import SwiftUI

extension Color {
    // Основные цвета из дизайна
    static let themeBackgroundStart = Color(hex: "#481CB4")
    static let themeBackgroundEnd = Color(hex: "#1F0C4E")
    static let themeCard = Color(hex: "#6D28D9").opacity(0.6)
    static let themeAccent = Color(hex: "#FACC15") // Желтый/золотой
    
    // Вспомогательные цвета
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let inactiveTab = Color.gray
}

// Помощник для работы с HEX-цветами
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


extension View {
    func size() -> CGSize {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        return window.screen.bounds.size
    }
}
