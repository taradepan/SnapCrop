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
    @StateObject private var editingViewModel = EditingViewModel(image: NSImage())
    @State private var canvasSize: CGSize = .zero

    var body: some View {
        Group {
            if captureEngine.capturedImage == nil {
                captureView
            } else {
                editingView
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .onChange(of: captureEngine.capturedImage) { _, newImage in
            if let newImage = newImage {
                editingViewModel.updateImage(newImage)
            }
        }
    }

    private var captureView: some View {
        NavigationSplitView {
            CaptureOptionsView(
                captureType: $captureEngine.captureType,
                selectedWindow: $captureEngine.selectedWindow,
                onCapture: {
                    Task {
                        await captureEngine.capture()
                    }
                }
            )
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            ScreenshotCanvasView(captureEngine: captureEngine, editingViewModel: editingViewModel, canvasSize: $canvasSize)
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private var editingView: some View {
        HStack(spacing: 0) {
            ScreenshotCanvasView(captureEngine: captureEngine, editingViewModel: editingViewModel, canvasSize: $canvasSize)
            
            EditingToolsView(viewModel: editingViewModel, canvasSize: $canvasSize) {
                // Action for "New Capture" button
                captureEngine.capturedImage = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
