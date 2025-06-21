//
//  CaptureOptionsView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI
import ScreenCaptureKit

struct CaptureOptionsView: View {
    @Binding var selectedMode: CaptureMode
    @Binding var selectedWindow: SCWindow?
    @ObservedObject var captureEngine: ScreenshotCaptureEngine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            captureModeSection
            if selectedMode == .window {
                windowSelectionSection
            }
            captureButtonSection
        }
        .padding()
        .frame(minWidth: 250)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SnapCrop")
                .font(.title2)
                .fontWeight(.bold)
            Text("Beautiful Screenshots")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var captureModeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Capture Mode")
                .font(.headline)
            
            ForEach(CaptureMode.allCases) { mode in
                captureModeButton(mode)
            }
        }
    }
    
    private func captureModeButton(_ mode: CaptureMode) -> some View {
        Button(action: {
            selectedMode = mode
            if mode == .window {
                Task {
                    await captureEngine.refreshWindows()
                }
            }
        }) {
            HStack {
                Image(systemName: mode.iconName)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.displayName)
                        .fontWeight(selectedMode == mode ? .semibold : .regular)
                    Text(mode.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if selectedMode == mode {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedMode == mode ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var windowSelectionSection: some View {
        if selectedMode == .window {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Select Window")
                        .font(.headline)
                    Spacer()
                    Button("Refresh") {
                        Task {
                            await captureEngine.refreshWindows()
                        }
                    }
                    .font(.caption)
                }
                
                if captureEngine.availableWindows.isEmpty {
                    Text("No windows available")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(captureEngine.availableWindows, id: \.windowID) { window in
                                windowButton(window)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
    }
    
    private func windowButton(_ window: SCWindow) -> some View {
        Button(action: {
            selectedWindow = window
        }) {
            HStack {
                Text(captureEngine.getWindowDisplayName(for: window))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Spacer()
                if selectedWindow?.windowID == window.windowID {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(selectedWindow?.windowID == window.windowID ? Color.blue.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var captureButtonSection: some View {
        VStack(spacing: 8) {
            Button(action: {
                Task {
                    await captureEngine.captureScreenshot(
                        mode: selectedMode,
                        selectedWindow: selectedWindow
                    )
                }
            }) {
                HStack {
                    if captureEngine.isCapturing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "camera")
                    }
                    Text(captureEngine.isCapturing ? "Capturing..." : "Capture Screenshot")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(captureEngine.isCapturing || (selectedMode == .window && selectedWindow == nil))
            
            if let error = captureEngine.captureError {
                Text(error) // ✅ FIXED: Remove .localizedDescription since error is already a String
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    CaptureOptionsView(
        selectedMode: .constant(.fullScreen),
        selectedWindow: .constant(nil),
        captureEngine: ScreenshotCaptureEngine()
    )
    .frame(width: 300, height: 500)
}
