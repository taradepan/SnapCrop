//
//  ScreenshotCanvasView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ScreenshotCanvasView: View {
    @ObservedObject var captureEngine: ScreenshotCaptureEngine
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastMagnification: CGFloat = 1.0
    @State private var isExporting: Bool = false // Hide controls when exporting
    @State private var gradientPadding: CGFloat = 48
    @State private var screenshotCornerRadius: CGFloat = 32
    @State private var gradientCornerRadius: CGFloat = 32
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                if let image = captureEngine.capturedImage {
                    GeometryReader { geometry in
                        let canvasSize = geometry.size
                        let composited = compositedImageWithGradient(
                            image,
                            gradientPadding: gradientPadding,
                            gradientCornerRadius: gradientCornerRadius,
                            screenshotCornerRadius: screenshotCornerRadius
                        )
                        let maxWidth = min(canvasSize.width * 0.85, composited.size.width)
                        let maxHeight = min(canvasSize.height * 0.7, composited.size.height)
                        let imgAspect = composited.size.width / max(composited.size.height, 1)
                        let fitWidth = min(maxWidth, maxHeight * imgAspect)
                        let fitHeight = min(maxHeight, maxWidth / imgAspect)
                        HStack {
                            Spacer()
                            Image(nsImage: composited)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: fitWidth, height: fitHeight)
                                .cornerRadius(gradientCornerRadius)
                                .shadow(color: .black.opacity(0.18), radius: 32, x: 0, y: 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: gradientCornerRadius)
                                        .stroke(Color.white.opacity(0.13), lineWidth: 2)
                                )
                                .scaleEffect(scale)
                                .offset(offset)
                            Spacer()
                        }
                        .frame(width: canvasSize.width, height: canvasSize.height)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .animation(.spring(), value: captureEngine.capturedImage)
                    // Floating toolbar below screenshot
                    if !isExporting {
                        HStack(spacing: 18) {
                            Button(action: { copyExportedImage() }) {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            Button(action: { saveExportedImage() }) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .controlSize(.large)
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    scale = 1.0
                                    offset = .zero
                                }
                            }) {
                                Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            Text("\(Int(scale * 100))%")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                                .frame(minWidth: 35)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                            Spacer(minLength: 0)
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("\(captureEngine.capturedImage?.size.width ?? 0, specifier: "%.0f") × \(captureEngine.capturedImage?.size.height ?? 0, specifier: "%.0f")")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.primary)
                                Text("\(formatFileSize(captureEngine.capturedImage!))")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 2)
                        .padding(.bottom, 32)
                        .padding(.top, 8)
                        .frame(maxWidth: 700)
                        .animation(.spring(), value: scale)
                    }
                } else if captureEngine.isCapturing {
                    Spacer()
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.blue)
                        }
                        VStack(spacing: 8) {
                            Text("Capturing Screenshot")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Please wait...")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Spacer()
                } else {
                    Spacer()
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 120, height: 120)
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.blue)
                        }
                        VStack(spacing: 12) {
                            Text("Ready to Capture")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Choose a capture mode from the sidebar and click\n\"Capture Screenshot\" to get started")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                        }
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            Text("Tip: Use trackpad gestures to zoom and pan captured images")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            // Add floating edit controls at bottom right
            if captureEngine.capturedImage != nil {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 12) {
                            HStack {
                                Text("Gradient Width")
                                    .font(.caption)
                                Slider(value: $gradientPadding, in: 0...200, step: 1)
                                    .frame(width: 120)
                                Text("\(Int(gradientPadding))")
                                    .font(.caption2)
                                    .frame(width: 32)
                            }
                            HStack {
                                Text("Gradient Radius")
                                    .font(.caption)
                                Slider(value: $gradientCornerRadius, in: 0...128, step: 1)
                                    .frame(width: 120)
                                Text("\(Int(gradientCornerRadius))")
                                    .font(.caption2)
                                    .frame(width: 32)
                            }
                            HStack {
                                Text("Screenshot Radius")
                                    .font(.caption)
                                Slider(value: $screenshotCornerRadius, in: 0...128, step: 1)
                                    .frame(width: 120)
                                Text("\(Int(screenshotCornerRadius))")
                                    .font(.caption2)
                                    .frame(width: 32)
                            }
                        }
                        .padding(14)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 2)
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onChange(of: captureEngine.capturedImage) { oldImage, newImage in
            if newImage != nil {
                withAnimation(.easeInOut(duration: 0.5)) {
                    scale = 1.0
                    offset = .zero
                }
            }
        }
    }
    
    private func saveImage() {
        guard let image = captureEngine.capturedImage else { return }
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "Screenshot-\(formatDateForFilename()).png"
        panel.message = "Save your beautiful screenshot"
        
        if panel.runModal() == .OK, let url = panel.url {
            do {
                try captureEngine.saveImage(image, to: url)
                print("✅ Screenshot saved to: \(url.path)")
            } catch {
                print("❌ Failed to save image: \(error)")
            }
        }
    }
    
    private func formatFileSize(_ image: NSImage) -> String {
        let pixels = image.size.width * image.size.height
        let estimatedBytes = pixels * 4 // RGBA
        
        if estimatedBytes < 1_000_000 {
            return String(format: "%.0f KB", estimatedBytes / 1_000)
        } else {
            return String(format: "%.1f MB", estimatedBytes / 1_000_000)
        }
    }
    
    private func formatDateForFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: Date())
    }
    
    // Export/copy helpers
    private func compositedImageWithGradient(_ screenshot: NSImage, gradientPadding: CGFloat, gradientCornerRadius: CGFloat, screenshotCornerRadius: CGFloat) -> NSImage {
        let finalSize = CGSize(width: screenshot.size.width + gradientPadding * 2, height: screenshot.size.height + gradientPadding * 2)
        let image = NSImage(size: finalSize)
        image.lockFocus()

        // 1. Create a rounded rect path for the gradient
        let bgPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: finalSize),
                                  xRadius: gradientCornerRadius, yRadius: gradientCornerRadius)
        bgPath.addClip() // This ensures only the rounded area is drawn, corners remain transparent

        // 2. Draw the gradient inside the clipped area
        let gradient = NSGradient(colors: [NSColor.systemPink, NSColor.systemBlue])!
        gradient.draw(in: NSRect(origin: .zero, size: finalSize), angle: 135)

        // 3. Draw the screenshot with its own rounded corners
        let targetRect = CGRect(x: gradientPadding, y: gradientPadding,
                                width: screenshot.size.width, height: screenshot.size.height)
        let screenshotPath = NSBezierPath(roundedRect: targetRect,
                                          xRadius: screenshotCornerRadius, yRadius: screenshotCornerRadius)
        screenshotPath.addClip()
        screenshot.draw(in: targetRect)

        image.unlockFocus()
        return image
    }
    
    private func copyExportedImage() {
        if let image = captureEngine.capturedImage {
            let composited = compositedImageWithGradient(
                image,
                gradientPadding: gradientPadding,
                gradientCornerRadius: gradientCornerRadius,
                screenshotCornerRadius: screenshotCornerRadius
            )
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            if let pngData = composited.pngData() {
                pasteboard.setData(pngData, forType: .png)
            } else {
                pasteboard.writeObjects([composited])
            }
        }
    }
    private func saveExportedImage() {
        if let image = captureEngine.capturedImage {
            let composited = compositedImageWithGradient(
                image,
                gradientPadding: gradientPadding,
                gradientCornerRadius: gradientCornerRadius,
                screenshotCornerRadius: screenshotCornerRadius
            )
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.png]
            panel.canCreateDirectories = true
            panel.nameFieldStringValue = "Screenshot-\(formatDateForFilename()).png"
            panel.message = "Save your beautiful screenshot"
            if panel.runModal() == .OK, let url = panel.url {
                do {
                    try composited.writePNG(to: url)
                } catch {
                    print("❌ Failed to save image: \(error)")
                }
            }
        }
    }
}

// MARK: - NSImage Export Helpers
extension NSImage {
    func pngData() -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }
    func jpgData(compression: CGFloat = 0.92) -> Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: compression])
    }
    func writePNG(to url: URL) throws {
        guard let data = self.pngData() else { throw NSError(domain: "NSImagePNG", code: 0, userInfo: nil) }
        try data.write(to: url)
    }
    func writeJPG(to url: URL, compression: CGFloat = 0.92) throws {
        guard let data = self.jpgData(compression: compression) else { throw NSError(domain: "NSImageJPG", code: 0, userInfo: nil) }
        try data.write(to: url)
    }
}

func calculateAccurateImageFrame(
    for image: NSImage,
    canvasSize: CGSize,
    scale: CGFloat,
    offset: CGSize
) -> CGRect {
    let imageSize = image.size
    let availableWidth = canvasSize.width - 32
    let availableHeight = canvasSize.height - 32
    let scaleX = availableWidth / imageSize.width
    let scaleY = availableHeight / imageSize.height
    let baseScale = min(scaleX, scaleY)
    let finalScale = baseScale * scale
    let displayWidth = imageSize.width * finalScale
    let displayHeight = imageSize.height * finalScale
    let imageX = (canvasSize.width - displayWidth) / 2 + offset.width
    let imageY = (canvasSize.height - displayHeight) / 2 + offset.height
    return CGRect(
        x: imageX,
        y: imageY,
        width: displayWidth,
        height: displayHeight
    )
}

private func compositedImageWithGradient(
    _ screenshot: NSImage,
    gradientPadding: CGFloat,
    gradientCornerRadius: CGFloat,
    screenshotCornerRadius: CGFloat
) -> NSImage {
    let finalSize = CGSize(width: screenshot.size.width + gradientPadding * 2,
                           height: screenshot.size.height + gradientPadding * 2)
    let image = NSImage(size: finalSize)
    image.lockFocus()

    // 1. Create a rounded rect path for the gradient
    let bgPath = NSBezierPath(roundedRect: NSRect(origin: .zero, size: finalSize),
                              xRadius: gradientCornerRadius, yRadius: gradientCornerRadius)
    bgPath.addClip() // This ensures only the rounded area is drawn, corners remain transparent

    // 2. Draw the gradient inside the clipped area
    let gradient = NSGradient(colors: [NSColor.systemPink, NSColor.systemBlue])!
    gradient.draw(in: NSRect(origin: .zero, size: finalSize), angle: 135)

    // 3. Draw the screenshot with its own rounded corners
    let targetRect = CGRect(x: gradientPadding, y: gradientPadding,
                            width: screenshot.size.width, height: screenshot.size.height)
    let screenshotPath = NSBezierPath(roundedRect: targetRect,
                                      xRadius: screenshotCornerRadius, yRadius: screenshotCornerRadius)
    screenshotPath.addClip()
    screenshot.draw(in: targetRect)

    image.unlockFocus()
    return image
}
