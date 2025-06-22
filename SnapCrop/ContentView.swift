//
//  ContentView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI
import ScreenCaptureKit

struct ContentView: View {
    @StateObject private var captureEngine = ScreenshotCaptureEngine()
    @State private var selectedMode: CaptureMode = .fullScreen
    @State private var selectedWindow: SCWindow?
    
    var body: some View {
        // Sidebar with capture options
        NavigationSplitView {
            CaptureOptionsView(
                selectedMode: $selectedMode,
                selectedWindow: $selectedWindow,
                captureEngine: captureEngine
            )
        } detail: {
            // Main canvas area
            ScreenshotCanvasView(captureEngine: captureEngine)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
}
