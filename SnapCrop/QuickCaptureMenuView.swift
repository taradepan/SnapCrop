//
//  QuickCaptureMenuView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI

struct QuickCaptureMenuView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SnapCrop")
                .font(.headline)
                .padding(.horizontal)
            
            Divider()
            
            Button("Capture Full Screen") {
                // We'll implement this next
                print("Quick capture: Full Screen")
            }
            
            Button("Capture Window") {
                print("Quick capture: Window")
            }
            
            Button("Capture Selection") {
                print("Quick capture: Selection")
            }
            
            Divider()
            
            Button("Open SnapCrop") {
                // Open main window
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    QuickCaptureMenuView()
}
