//
//  PredefinedGradient.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI

struct PredefinedGradient: Identifiable, Hashable {
    let id = UUID()
    let displayName: String
    let gradient: LinearGradient
    
    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Conformance to Equatable
    static func == (lhs: PredefinedGradient, rhs: PredefinedGradient) -> Bool {
        lhs.id == rhs.id
    }
    
    static let all: [PredefinedGradient] = [
        .init(displayName: "Sunset", gradient: LinearGradient(colors: [.orange, .red, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)),
        .init(displayName: "Ocean", gradient: LinearGradient(colors: [.blue, .green], startPoint: .top, endPoint: .bottom)),
        .init(displayName: "Twilight", gradient: LinearGradient(colors: [Color(hex: "#0f2027"), Color(hex: "#203a43"), Color(hex: "#2c5364")], startPoint: .top, endPoint: .bottom)),
        .init(displayName: "Emerald", gradient: LinearGradient(colors: [Color(hex: "#237A57"), Color(hex: "#093028")], startPoint: .topLeading, endPoint: .bottomTrailing)),
        .init(displayName: "Sky", gradient: LinearGradient(colors: [Color(hex: "#0072ff"), Color(hex: "#00c6ff")], startPoint: .top, endPoint: .bottom)),
        .init(displayName: "Rose", gradient: LinearGradient(colors: [Color(hex: "#F390A4"), Color(hex: "#FDE9E8")], startPoint: .top, endPoint: .bottom)),
        .init(displayName: "Graphite", gradient: LinearGradient(colors: [Color(hex: "#434343"), Color(hex: "#000000")], startPoint: .top, endPoint: .bottom)),
    ]
}

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
            (a, r, g, b) = (1, 1, 1, 0)
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