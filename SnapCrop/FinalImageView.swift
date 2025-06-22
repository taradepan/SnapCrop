//
//  FinalImageView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-23.
//

import SwiftUI

/// A view that represents the final, composited image with all effects applied.
/// This view is used for both on-screen rendering and for exporting.
struct FinalImageView: View {
    let sourceImage: NSImage
    
    // Editing Properties
    let gradientPadding: CGFloat
    let screenshotCornerRadius: CGFloat
    let gradientCornerRadius: CGFloat
    let activeGradient: PredefinedGradient
    let showShadow: Bool
    let shadowOpacity: Double
    let shadowRadius: CGFloat
    let shadowYOffset: CGFloat

    var body: some View {
        GeometryReader { geo in
            let availableWidth = max(geo.size.width - 2 * gradientPadding, 1)
            let availableHeight = max(geo.size.height - 2 * gradientPadding, 1)
            ZStack {
                RoundedRectangle(cornerRadius: gradientCornerRadius, style: .continuous)
                    .fill(activeGradient.gradient)
                    .frame(width: geo.size.width, height: geo.size.height)

                ScreenshotWithEffects(
                    image: sourceImage,
                    screenshotCornerRadius: screenshotCornerRadius,
                    showShadow: showShadow,
                    shadowOpacity: shadowOpacity,
                    shadowRadius: shadowRadius,
                    shadowYOffset: shadowYOffset
                )
                .aspectRatio(sourceImage.size, contentMode: .fit)
                .frame(width: availableWidth, height: availableHeight)
            }
        }
        .compositingGroup()
    }
} 