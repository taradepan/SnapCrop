//
//  CaptureTypes.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import ScreenCaptureKit
import SwiftUI

enum CaptureType: String, CaseIterable, Identifiable {
    case fullScreen = "Full Screen"
    case window = "Window"
    case selection = "Selection"
    
    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .fullScreen: return "macwindow"
        case .window: return "display"
        case .selection: return "selection.pin.in.out"
        }
    }
    
    var description: String {
        switch self {
        case .fullScreen: return "Capture the entire screen"
        case .window: return "Capture a specific window"
        case .selection: return "Select an area to capture"
        }
    }
}

enum CaptureError: Error, LocalizedError {
    case permissionDenied
    case noDisplayFound
    case noWindowSelected
    case imageCreationError
    case failedToSaveImage

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Screen recording permission denied. Please grant permission in System Settings."
        case .noDisplayFound:
            return "Could not find a display to capture."
        case .noWindowSelected:
            return "No window was selected for capture."
        case .imageCreationError:
            return "There was an error creating the image."
        case .failedToSaveImage:
            return "Failed to save the captured image."
        }
    }
}

extension Notification.Name {
    /// Notification to request that the current canvas content be rendered and copied to the clipboard.
    static let requestRenderAndCopy = Notification.Name("com.snapcrop.requestRenderAndCopy")
    
    /// Notification to request that the current canvas content be rendered and saved to a file.
    static let requestRenderAndSave = Notification.Name("com.snapcrop.requestRenderAndSave")
}
