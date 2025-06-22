//
//  GradientPicker.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI

struct GradientPicker: View {
    @Binding var selection: PredefinedGradient

    var body: some View {
        Picker("Gradient", selection: $selection) {
            ForEach(PredefinedGradient.all) { gradient in
                Text(gradient.displayName).tag(gradient)
            }
        }
        .pickerStyle(.menu)
    }
} 