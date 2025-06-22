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
    @ObservedObject var editingViewModel: EditingViewModel
    @Binding var canvasSize: CGSize
    @State private var screenshotCornerRadius: CGFloat = 32
    @State private var gradientCornerRadius: CGFloat = 32
    @State private var selectedGradient: GradientStyle = .pinkBlue
    @State private var exportSuccess: Bool = false
    @State private var exportError: String?
    @State private var showExportAlert: Bool = false
    @State private var gradientPadding: CGFloat = 32

    var body: some View {
                    ZStack {
            Color(nsColor: .underPageBackgroundColor).ignoresSafeArea()

            if captureEngine.capturedImage != nil {
                EditingCanvas(viewModel: editingViewModel, canvasSize: $canvasSize, showGradient: editingViewModel.showGradient)
            } else {
                PlaceholderView()
            }
        }
        .alert("Export Failed", isPresented: $editingViewModel.showExportErrorAlert, presenting: editingViewModel.exportError) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error)
        }
    }

    private var compositedImageData: Data? {
        guard let image = captureEngine.capturedImage else { return nil }
        let composited = compositedImageWithGradient(
            image,
            gradientPadding: gradientPadding,
            gradientCornerRadius: gradientCornerRadius,
            screenshotCornerRadius: screenshotCornerRadius
        )
        return composited.pngData
    }

    private func saveExportedImage() {
        print("🚨 saveExportedImage() called")
        guard let image = captureEngine.capturedImage else {
            print("❌ No captured image available for export.")
            return
        }
        let composited = compositedImageWithGradient(
            image,
            gradientPadding: gradientPadding,
            gradientCornerRadius: gradientCornerRadius,
            screenshotCornerRadius: screenshotCornerRadius
        )
        print("🖼️ Composited image size: \(composited.size.width)x\(composited.size.height)")
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = "Screenshot-\(formatDateForFilename()).png"
        panel.message = "Save your beautiful screenshot"
        print("📂 Opening NSSavePanel...")
        let result = panel.runModal()
        print("📂 NSSavePanel result: \(result.rawValue)")
        if result == .OK, let url = panel.url {
            print("💾 Saving to URL: \(url.path)")
            do {
                try composited.writePNG(to: url)
                print("✅ Screenshot saved to: \(url.path)")
                exportSuccess = true
                exportError = nil
                showExportAlert = true
            } catch {
                print("❌ Failed to save image: \(error)")
                exportSuccess = false
                exportError = error.localizedDescription
                showExportAlert = true
            }
        } else {
            print("❌ NSSavePanel was cancelled or no URL selected.")
        }
    }
}

// MARK: - Subviews

struct EditingCanvas: View {
    @ObservedObject var viewModel: EditingViewModel
    @State var scale: CGFloat = 1.0
    @State var offset: CGSize = .zero
    @Binding var canvasSize: CGSize
    var showGradient: Bool
    
    var body: some View {
        GeometryReader { geo in
            FinalImageView(
                sourceImage: viewModel.sourceImage,
                gradientPadding: viewModel.gradientPadding,
                screenshotCornerRadius: viewModel.screenshotCornerRadius,
                gradientCornerRadius: viewModel.gradientCornerRadius,
                activeGradient: viewModel.activeGradient,
                showGradient: showGradient,
                showShadow: viewModel.showShadow,
                shadowOpacity: viewModel.shadowOpacity,
                shadowRadius: viewModel.shadowRadius,
                shadowYOffset: viewModel.shadowYOffset
            )
            .aspectRatio(
                CGSize(
                    width: viewModel.sourceImage.size.width + viewModel.gradientPadding * 2,
                    height: viewModel.sourceImage.size.height + viewModel.gradientPadding * 2
                ),
                contentMode: .fit
            )
            .onAppear { canvasSize = geo.size }
            .onChange(of: geo.size) { canvasSize = geo.size }
            .scaleEffect(scale)
            .offset(offset)
            .gesture(magnificationGesture)
            .gesture(dragGesture)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = value
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            offset = .zero
                        }
                    }
    }
}

private struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.accentColor)

            Text("Ready to Capture")
                .font(.largeTitle.weight(.bold))
            
            Text("Choose a capture mode from the sidebar to begin.")
                .font(.title3)
                    .foregroundColor(.secondary)
        }
    }
}

// MARK: - Modern Glassy Button Style
struct GlassyFloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GlassyButton(configuration: configuration)
    }
    
    private struct GlassyButton: View {
        let configuration: Configuration
        @State private var isHovered = false
        
        var body: some View {
            configuration.label
                .padding(12)
                .background(
                    BlurView(material: .sidebar)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.13), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(configuration.isPressed ? 0.08 : 0.16), radius: configuration.isPressed ? 4 : 12, y: 2)
                .scaleEffect(configuration.isPressed ? 0.96 : (isHovered ? 1.08 : 1.0))
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
                .onHover { hovering in
                    isHovered = hovering
                }
        }
    }
}

// Helper for BlurView
struct BlurView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct ImageFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(regularFileWithContents: data)
    }
}

// MARK: - NSImage Extension
extension NSImage {
    func writePNG(to url: URL) throws {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffRepresentation) else {
            throw NSError(domain: "NSImagePNGError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get TIFF representation of image."])
        }
        guard let data = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "NSImagePNGError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create PNG data from image."])
        }
        try data.write(to: url)
    }

    var pngData: Data? {
        guard let tiffData = self.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }
}

// If GradientStyle is not already defined, define it here:
enum GradientStyle: String, CaseIterable, Identifiable {
    case pinkBlue, orangePurple, greenYellow
    var id: String { rawValue }
    // Add your gradient definitions here if needed
}

// If compositedImageWithGradient is not already defined, add a stub:
func compositedImageWithGradient(
    _ image: NSImage,
    gradientPadding: CGFloat,
    gradientCornerRadius: CGFloat,
    screenshotCornerRadius: CGFloat
) -> NSImage {
    // TODO: Implement your compositing logic
    return image // Replace with actual composited image
}

// Helper for filename formatting
func formatDateForFilename() -> String {
        let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: Date())
    }


 
