//
//  CaptureOptionsView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI
import ScreenCaptureKit

struct CaptureOptionsView: View {
    @Binding var captureType: CaptureType
    @Binding var selectedWindow: SCWindow?
    let onCapture: () -> Void
    
    @StateObject private var windowManager = WindowManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            modeSelection
            if captureType == .window {
                windowSelectionSection
            }
            Spacer()
            captureButton
        }
        .padding(22)
        .background(.regularMaterial)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "camera.aperture")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom))
            VStack(alignment: .leading, spacing: 2) {
                Text("SnapCrop")
                    .font(.title.bold())
                Text("Beautiful Screenshots")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var modeSelection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Capture Mode")
                .font(.headline.weight(.semibold))
                .foregroundColor(.secondary)
            ForEach(CaptureType.allCases) { mode in
                modeButton(for: mode)
            }
        }
    }
    
    private func modeButton(for mode: CaptureType) -> some View {
        Button(action: {
            captureType = mode
            if mode == .window {
                windowManager.refreshWindows()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: mode.systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(captureType == mode ? .blue : .secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(mode.rawValue)
                        .fontWeight(captureType == mode ? .semibold : .regular)
                        .foregroundColor(captureType == mode ? .blue : .primary)
                    Text(mode.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if captureType == mode {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(captureType == mode ? Color.blue.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private var captureButton: some View {
        Button(action: onCapture) {
            Label("Capture", systemImage: "camera")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
        .controlSize(.large)
    }
    
    @ViewBuilder
    private var windowSelectionSection: some View {
        if captureType == .window {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Select Window")
                        .font(.headline)
                    Spacer()
                    Button("Refresh") {
                        windowManager.refreshWindows()
                    }
                    .font(.caption)
                }
                
                if windowManager.availableWindows.isEmpty {
                    Text("No windows available")
                        .foregroundStyle(.secondary)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(windowManager.availableWindows, id: \.windowID) { window in
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
                Text(windowManager.getWindowDisplayName(for: window))
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

@MainActor
class WindowManager: ObservableObject {
    @Published var availableWindows: [SCWindow] = []

    init() {
        refreshWindows()
    }

    func refreshWindows() {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                self.availableWindows = content.windows.filter {
                    guard let app = $0.owningApplication else { return false }
                    guard $0.isOnScreen else { return false }
                    guard $0.title != nil && !$0.title!.isEmpty else { return false }
                    return app.bundleIdentifier != "com.apple.dt.xctest.tool"
                }
            } catch {
                print("Error refreshing windows: \(error.localizedDescription)")
            }
        }
    }
    
    func getWindowDisplayName(for window: SCWindow) -> String {
        let appName = window.owningApplication?.applicationName ?? "Unknown App"
        let title = window.title ?? "Unknown Window"
        return "\(appName) - \(title)"
    }
}


#Preview {
    CaptureOptionsView(
        captureType: .constant(.window),
        selectedWindow: .constant(nil),
        onCapture: {}
    )
    .frame(width: 320, height: 600)
}
