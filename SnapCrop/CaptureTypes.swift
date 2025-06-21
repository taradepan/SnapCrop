//
//  CaptureTypes.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import Foundation

/// Capture mode options for screenshots
enum CaptureMode: String, CaseIterable, Identifiable {
    case fullScreen = "fullScreen"
    case window = "window"
    case selection = "selection"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .fullScreen:
            return "Full Screen"
        case .window:
            return "Window"
        case .selection:
            return "Selection"
        }
    }
    
    var iconName: String {
        switch self {
        case .fullScreen:
            return "rectangle.dashed"
        case .window:
            return "macwindow"
        case .selection:
            return "selection.pin.in.out"
        }
    }
    
    var description: String {
        switch self {
        case .fullScreen:
            return "Capture the entire screen"
        case .window:
            return "Capture a specific window"
        case .selection:
            return "Select area to capture"
        }
    }
}

/// Screenshot quality options
enum CaptureQuality: String, CaseIterable, Identifiable {
    case standard = "standard"
    case high = "high"
    case retina = "retina"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .standard:
            return "Standard"
        case .high:
            return "High Quality"
        case .retina:
            return "Retina"
        }
    }
    
    var scaleFactor: CGFloat {
        switch self {
        case .standard:
            return 1.0
        case .high:
            return 1.5
        case .retina:
            return 2.0
        }
    }
}

/// Export format options
enum ExportFormat: String, CaseIterable, Identifiable {
    case png = "png"
    case jpg = "jpg"
    case heic = "heic"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .png:
            return "PNG"
        case .jpg:
            return "JPEG"
        case .heic:
            return "HEIC"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpg:
            return "jpg"
        case .heic:
            return "heic"
        }
    }
}
