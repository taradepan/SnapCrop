//
//  ScreenshotWithEffects.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI

struct ScreenshotWithEffects: View {
    let image: NSImage
    let screenshotCornerRadius: CGFloat
    let showShadow: Bool
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowYOffset: CGFloat

    var body: some View {
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: screenshotCornerRadius, style: .continuous))
            .shadow(
                color: .black.opacity(showShadow ? shadowOpacity : 0),
                radius: shadowRadius,
                y: shadowYOffset
            )
    }
} 