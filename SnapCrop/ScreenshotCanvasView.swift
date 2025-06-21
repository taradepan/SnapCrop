//
//  ScreenshotCanvasView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI

struct ScreenshotCanvasView: View {
    @ObservedObject var captureEngine: ScreenshotCaptureEngine
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastMagnification: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 0) {
            if let image = captureEngine.capturedImage {
                // Main image display area
                GeometryReader { geometry in
                    ZStack {
                        // Clean transparent background
                        Color.clear
                        
                        // Much more aggressive scaling to fill the canvas
                        let imageSize = image.size
                        let canvasSize = geometry.size
                        
                        // Use almost the full canvas size with very minimal padding
                        let availableWidth = canvasSize.width - 8   // Reduced from 20 to 8
                        let availableHeight = canvasSize.height - 8  // Reduced from 20 to 8
                        
                        let scaleX = availableWidth / imageSize.width
                        let scaleY = availableHeight / imageSize.height
                        
                        // Use the smaller scale to fit, but be much more aggressive
                        // This will make the image fill much more of the available space
                        let fitScale = min(scaleX, scaleY)
                        
                        // Apply a boost factor to make images appear larger by default
                        let boostFactor: CGFloat = 1.15  // 15% larger than perfect fit
                        let defaultScale = fitScale * boostFactor
                        
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale * defaultScale)  // Use boosted default scale
                            .offset(offset)
                            .cornerRadius(4)  // Slightly smaller corner radius
                            .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)  // Subtler shadow
                            .gesture(
                                SimultaneousGesture(
                                    // Zoom gesture
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastMagnification
                                            scale *= delta
                                            lastMagnification = value
                                        }
                                        .onEnded { _ in
                                            lastMagnification = 1.0
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                scale = max(0.1, min(scale, 10.0))
                                            }
                                        },
                                    
                                    // Pan gesture
                                    DragGesture()
                                        .onChanged { value in
                                            offset = value.translation
                                        }
                                        .onEnded { _ in
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                let maxOffset = min(canvasSize.width, canvasSize.height) * 0.8  // Increased from 0.6
                                                offset.width = max(-maxOffset, min(maxOffset, offset.width))
                                                offset.height = max(-maxOffset, min(maxOffset, offset.height))
                                            }
                                        }
                                )
                            )
                            .animation(.easeInOut(duration: 0.1), value: scale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Compact control bar
                HStack(spacing: 16) {
                    // Action buttons
                    HStack(spacing: 10) {
                        Button(action: { captureEngine.copyImageToClipboard(image) }) {
                            HStack(spacing: 5) {
                                Image(systemName: "doc.on.clipboard")
                                Text("Copy")
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                        
                        Button(action: { saveImage() }) {
                            HStack(spacing: 5) {
                                Image(systemName: "square.and.arrow.down")
                                Text("Save")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                    }
                    
                    Spacer()
                    
                    // Zoom controls
                    HStack(spacing: 10) {
                        Button("Reset View") {  // Changed from "Fit to Screen" to be more accurate
                            withAnimation(.easeInOut(duration: 0.4)) {
                                scale = 1.0
                                offset = .zero
                            }
                        }
                        .font(.caption)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        // Show actual zoom level - simplified calculation using geometry
                        Text("\(Int(scale * 100))%")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(minWidth: 35)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    // Image info
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(Int(image.size.width)) × \(Int(image.size.height))")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                        
                        Text("\(formatFileSize(image))")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 0))
                
            } else if captureEngine.isCapturing {
                // Capturing state
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
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Please wait...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            } else {
                // Empty state
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 12) {
                        Text("Ready to Capture")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Choose a capture mode from the sidebar and click\n\"Capture Screenshot\" to get started")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text("Tip: Use trackpad gestures to zoom and pan captured images")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .onChange(of: captureEngine.capturedImage) { _, newImage in
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
}
