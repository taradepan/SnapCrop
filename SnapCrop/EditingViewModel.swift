//
//  EditingViewModel.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI
import AppKit

@MainActor
class EditingViewModel: ObservableObject {
    
    // The source image
    private(set) var sourceImage: NSImage
    
    // Published properties for UI controls
    @Published var gradientPadding: CGFloat = 48
    @Published var screenshotCornerRadius: CGFloat = 24
    @Published var gradientCornerRadius: CGFloat = 32
    @Published var activeGradient: PredefinedGradient = PredefinedGradient.all.first!
    
    @Published var showShadow: Bool = true
    @Published var shadowOpacity: Double = 0.35
    @Published var shadowRadius: CGFloat = 45
    @Published var shadowYOffset: CGFloat = 25
    
    @Published var showGradient: Bool = true
    
    // Published properties for alerts
    @Published var showCopiedAlert = false
    @Published var showExportSuccessAlert = false
    @Published var showExportErrorAlert = false
    @Published var exportError: String?

    init(image: NSImage) {
        self.sourceImage = image
    }
    
    func updateImage(_ newImage: NSImage) {
        self.sourceImage = newImage
    }
    
    // MARK: - Rendering
    
    @MainActor
    func render(at size: CGSize) -> NSImage? {
        let viewToRender = FinalImageView(
            sourceImage: sourceImage,
            gradientPadding: gradientPadding,
            screenshotCornerRadius: screenshotCornerRadius,
            gradientCornerRadius: gradientCornerRadius,
            activeGradient: activeGradient,
            showGradient: showGradient,
            showShadow: showShadow,
            shadowOpacity: shadowOpacity,
            shadowRadius: shadowRadius,
            shadowYOffset: shadowYOffset
        )
        .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: viewToRender)
        renderer.scale = 2.0 // for Retina quality

        guard let nsImage = renderer.nsImage else {
            print("Failed to render image")
            return nil
        }
        print("Exported image size: \(nsImage.size)")
        return nsImage
    }
    
    // MARK: - Actions
    
    func copyToClipboard(_ canvasSize: CGSize) {
        guard let finalImage = render(at: canvasSize) else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        if pasteboard.writeObjects([finalImage]) {
            showCopiedAlert = true
        }
    }

    func saveToFile(_ canvasSize: CGSize) {
        guard let finalImage = render(at: canvasSize) else {
            exportError = "Could not render the final image."
            showExportErrorAlert = true
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "Screenshot-\(Date().formatted(.iso8601)).png"
        
        if panel.runModal() == .OK {
            guard let url = panel.url else {
                exportError = "A valid file location was not selected."
                showExportErrorAlert = true
                return
            }
            do {
                try finalImage.writePNG(to: url)
                showExportSuccessAlert = true
            } catch {
                exportError = "Failed to save the image: \(error.localizedDescription)"
                showExportErrorAlert = true
            }
        }
    }
} 