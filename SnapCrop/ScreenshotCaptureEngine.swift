//
//  ScreenshotCaptureEngine.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import Foundation
import ScreenCaptureKit
import AppKit

@MainActor
class ScreenshotCaptureEngine: ObservableObject {
    @Published var capturedImage: NSImage?
    @Published var isCapturing = false
    @Published var captureError: String?
    @Published var availableWindows: [SCWindow] = []
    @Published var hasPermissions = false
    
    init() {
        print("📱 ScreenshotCaptureEngine initialized")
        Task {
            await checkPermissions()
        }
    }
    
    /// Check screen recording permissions
    func checkPermissions() async {
        do {
            let availableContent = try await SCShareableContent.current
            self.hasPermissions = true
            self.availableWindows = filterUsefulWindows(availableContent.windows)
            print("✅ Permissions granted, found \(availableWindows.count) useful windows")
        } catch {
            self.hasPermissions = false
            self.captureError = "Screen recording permission required. Please grant permission in System Preferences > Privacy & Security > Screen Recording"
            print("❌ Permission error: \(error)")
        }
    }
    
    /// Filter windows to show only useful application windows
    private func filterUsefulWindows(_ windows: [SCWindow]) -> [SCWindow] {
        return windows.filter { window in
            // Must be on screen
            guard window.isOnScreen else { return false }
            
            // Must have a title
            guard let title = window.title, !title.isEmpty else { return false }
            
            // Must have an owning application
            guard let app = window.owningApplication else { return false }
            
            // Skip system/utility windows by title
            let systemTitles = [
                "Menubar",
                "Menu Bar",
                "Dock",
                "Desktop",
                "Wallpaper",
                "Control Center",
                "Notification Center",
                "Spotlight",
                "Mission Control",
                "Window Server",
                "CoreGraphics"
            ]
            
            for systemTitle in systemTitles {
                if title.localizedCaseInsensitiveContains(systemTitle) {
                    return false
                }
            }
            
            // Skip windows from system applications
            let systemApps = [
                "WindowServer",
                "Dock",
                "ControlCenter",
                "NotificationCenter",
                "SystemUIServer",
                "Spotlight",
                "Wallpaper"
            ]
            
            if systemApps.contains(app.applicationName) {
                return false
            }
            
            // Skip very small windows (likely UI elements)
            if window.frame.width < 100 || window.frame.height < 50 {
                return false
            }
            
            // Skip windows that are likely offscreen or utility windows
            if title.hasPrefix("Item-") ||
               title.contains("Offscreen") ||
               title.contains("Hidden") ||
               title.contains("Utility") {
                return false
            }
            
            return true
        }
        .sorted { window1, window2 in
            // Sort by application name, then by title
            if let app1 = window1.owningApplication?.applicationName,
               let app2 = window2.owningApplication?.applicationName {
                if app1 != app2 {
                    return app1 < app2
                }
            }
            
            let title1 = window1.title ?? ""
            let title2 = window2.title ?? ""
            return title1 < title2
        }
    }
    
    /// Capture screenshot based on mode
    func captureScreenshot(mode: CaptureMode, selectedWindow: SCWindow? = nil) async {
        guard hasPermissions else {
            await checkPermissions()
            return
        }
        
        switch mode {
        case .selection:
            // Use macOS built-in selection tool
            await captureWithNativeSelection()
        case .fullScreen:
            // Hide app for full screen capture
            await captureFullScreenWithHiddenApp()
        default:
            // Regular window capture (don't hide app)
            await performRegularCapture(mode: mode, selectedWindow: selectedWindow)
        }
    }
    
    /// Capture full screen with SnapCrop hidden
    private func captureFullScreenWithHiddenApp() async {
        isCapturing = true
        captureError = nil
        
        // Hide the app so it doesn't appear in the screenshot
        NSApplication.shared.hide(nil)
        
        // Wait a bit to ensure the app is fully hidden and screen has updated
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        
        do {
            let image = try await performCapture(mode: .fullScreen, selectedWindow: nil)
            self.capturedImage = image
            print("✅ Full screen screenshot captured successfully (with app hidden)")
        } catch {
            self.captureError = "Failed to capture full screen screenshot: \(error.localizedDescription)"
            print("❌ Full screen capture error: \(error)")
        }
        
        // Show the app again
        NSApplication.shared.unhideWithoutActivation()
        
        isCapturing = false
    }
    
    /// Use macOS native screenshot selection (like Cmd+Shift+4)
    private func captureWithNativeSelection() async {
        isCapturing = true
        captureError = nil
        
        // Create temporary file for screenshot
        let tempDir = NSTemporaryDirectory()
        let tempFilename = "snapcrop_selection_\(Date().timeIntervalSince1970).png"
        let tempPath = tempDir + tempFilename
        
        // Hide the app temporarily so it doesn't interfere with selection
        NSApplication.shared.hide(nil)
        
        // Small delay to ensure app is hidden
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await withCheckedContinuation { continuation in
            // Use macOS built-in screencapture tool with selection mode
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            process.arguments = [
                "-s",        // Interactive selection mode (like Cmd+Shift+4)
                "-x",        // Don't play camera sound
                "-t", "png", // PNG format
                tempPath     // Output file path
            ]
            
            process.terminationHandler = { [weak self] process in
                Task { @MainActor in
                    // Show the app again
                    NSApplication.shared.unhideWithoutActivation()
                    
                    if process.terminationStatus == 0 {
                        // Success - load the captured image
                        if let image = NSImage(contentsOfFile: tempPath) {
                            self?.capturedImage = image
                            print("✅ Native selection screenshot captured successfully")
                        } else {
                            self?.captureError = "Failed to load captured screenshot"
                        }
                    } else {
                        // User cancelled or error occurred
                        print("ℹ️ Screenshot selection cancelled or failed")
                    }
                    
                    // Clean up temp file
                    try? FileManager.default.removeItem(atPath: tempPath)
                    
                    self?.isCapturing = false
                    continuation.resume()
                }
            }
            
            do {
                try process.run()
            } catch {
                Task { @MainActor in
                    NSApplication.shared.unhideWithoutActivation()
                    self.captureError = "Failed to start screenshot selection: \(error.localizedDescription)"
                    self.isCapturing = false
                    continuation.resume()
                }
            }
        }
    }
    
    /// Regular capture for window mode (doesn't hide app)
    private func performRegularCapture(mode: CaptureMode, selectedWindow: SCWindow?) async {
        isCapturing = true
        captureError = nil
        
        do {
            let image = try await performCapture(mode: mode, selectedWindow: selectedWindow)
            self.capturedImage = image
            print("✅ Screenshot captured successfully")
        } catch {
            self.captureError = "Failed to capture screenshot: \(error.localizedDescription)"
            print("❌ Capture error: \(error)")
        }
        
        isCapturing = false
    }
    
    /// Perform the actual screenshot capture using ScreenCaptureKit
    private func performCapture(mode: CaptureMode, selectedWindow: SCWindow?) async throws -> NSImage {
        let availableContent = try await SCShareableContent.current
        
        let filter: SCContentFilter
        let configuration = SCStreamConfiguration()
        
        switch mode {
        case .fullScreen:
            guard let display = availableContent.displays.first else {
                throw CaptureError.noDisplayFound
            }
            filter = SCContentFilter(display: display, excludingWindows: [])
            configuration.width = display.width
            configuration.height = display.height
            
        case .window:
            guard let window = selectedWindow else {
                throw CaptureError.noWindowSelected
            }
            filter = SCContentFilter(desktopIndependentWindow: window)
            configuration.width = Int(window.frame.width)
            configuration.height = Int(window.frame.height)
            
        case .selection:
            // This case is handled in captureWithNativeSelection()
            throw CaptureError.noDisplayFound
        }
        
        // Configure for high quality capture
        configuration.pixelFormat = kCVPixelFormatType_32BGRA
        configuration.showsCursor = true
        configuration.scalesToFit = false
        
        // Capture the screenshot
        let image = try await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: configuration
        )
        
        // Convert CGImage to NSImage
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        return nsImage
    }
    
    /// Refresh available windows
    func refreshWindows() async {
        do {
            let availableContent = try await SCShareableContent.current
            self.availableWindows = filterUsefulWindows(availableContent.windows)
            print("🔄 Refreshed windows: \(availableWindows.count) useful windows found")
        } catch {
            self.captureError = "Failed to refresh windows: \(error.localizedDescription)"
            print("❌ Refresh error: \(error)")
        }
    }
    
    /// Get window display name with better formatting
    func getWindowDisplayName(for window: SCWindow) -> String {
        guard let title = window.title, !title.isEmpty,
              let app = window.owningApplication else {
            return "Unknown Window"
        }
        
        let appName = app.applicationName
        
        // If title is same as app name, just show app name
        if title == appName {
            return appName
        }
        
        // If title contains app name, just show title
        if title.contains(appName) {
            return title
        }
        
        // Otherwise show both: "Document - TextEdit"
        return "\(title) - \(appName)"
    }
    
    /// Save image to file
    func saveImage(_ image: NSImage, to url: URL) throws {
        guard let tiffData = image.tiffRepresentation,
              let bitmapRep = NSBitmapImageRep(data: tiffData) else {
            throw CaptureError.failedToSaveImage
        }
        
        let pngData = bitmapRep.representation(using: .png, properties: [:])
        try pngData?.write(to: url)
    }
    
    /// Copy to clipboard
    func copyImageToClipboard(_ image: NSImage) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
    }
}

// MARK: - Capture Errors
enum CaptureError: LocalizedError {
    case noDisplayFound
    case noWindowSelected
    case failedToSaveImage
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .noDisplayFound:
            return "No display found for capture"
        case .noWindowSelected:
            return "No window selected for capture"
        case .failedToSaveImage:
            return "Failed to save image"
        case .permissionDenied:
            return "Screen recording permission denied"
        }
    }
}
