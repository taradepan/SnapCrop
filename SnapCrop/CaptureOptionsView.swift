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
        VStack(alignment: .leading, spacing: 20) {
            // Logo and App Name
            HStack(spacing: 10) {
                Image(systemName: "camera.aperture")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom))
                VStack(alignment: .leading, spacing: 2) {
                    Text("SnapCrop")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                    Text("Beautiful Screenshots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Capture Mode Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Capture Mode")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.secondary)
                ForEach(CaptureMode.allCases) { mode in
                    Button(action: {
                        selectedMode = mode
                        if mode == .window {
                            Task { await captureEngine.refreshWindows() }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: mode.iconName)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(selectedMode == mode ? .blue : .secondary)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(mode.displayName)
                                    .fontWeight(selectedMode == mode ? .semibold : .regular)
                                    .foregroundColor(selectedMode == mode ? .blue : .primary)
                                Text(mode.description)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if selectedMode == mode {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedMode == mode ? Color.blue.opacity(0.12) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)

            // Window selection (if needed)
            if selectedMode == .window {
                windowSelectionSection
            }

            Spacer()

            // Capture Button
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
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.large)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.08), radius: 8, y: 2)
                .padding(.top, 8)

                if let error = captureEngine.captureError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
            }
        }
        .padding(22)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 2)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
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
}

#Preview {
    CaptureOptionsView(
        selectedMode: .constant(.fullScreen),
        selectedWindow: .constant(nil),
        captureEngine: ScreenshotCaptureEngine()
    )
    .frame(width: 300, height: 500)
}
