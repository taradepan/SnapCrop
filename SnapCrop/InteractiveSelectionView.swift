//
//  InteractiveSelectionView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI

struct InteractiveSelectionView: View {
    let screenBounds: CGRect
    let onSelection: (CGRect) -> Void
    let onCancel: () -> Void
    
    @State private var startPoint: CGPoint = .zero
    @State private var currentPoint: CGPoint = .zero
    @State private var isSelecting = false
    @State private var showInstructions = true
    
    private var selectionRect: CGRect {
        guard isSelecting else { return .zero }
        
        let minX = min(startPoint.x, currentPoint.x)
        let minY = min(startPoint.y, currentPoint.y)
        let maxX = max(startPoint.x, currentPoint.x)
        let maxY = max(startPoint.y, currentPoint.y)
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent overlay covering entire screen
            Color.black.opacity(0.3)
                .ignoresSafeArea(.all)
            
            // Clear selection area
            if isSelecting && selectionRect.width > 0 && selectionRect.height > 0 {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: selectionRect.width, height: selectionRect.height)
                    .position(x: selectionRect.midX, y: selectionRect.midY)
                    .overlay(
                        // Selection border
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 2)
                            .frame(width: selectionRect.width, height: selectionRect.height)
                            .position(x: selectionRect.midX, y: selectionRect.midY)
                    )
                    .overlay(
                        // Size label
                        Text("\(Int(selectionRect.width)) × \(Int(selectionRect.height))")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.blue)
                            .cornerRadius(4)
                            .position(x: selectionRect.midX, y: selectionRect.minY - 15)
                    )
            }
            
            // Instructions (show when not selecting)
            if showInstructions && !isSelecting {
                VStack(spacing: 12) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("Drag to select area")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Press ESC to cancel")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(20)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            }
        }
        .contentShape(Rectangle()) // Make entire area clickable
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    if !isSelecting {
                        startPoint = value.startLocation
                        isSelecting = true
                        showInstructions = false
                    }
                    currentPoint = value.location
                }
                .onEnded { _ in
                    if selectionRect.width > 10 && selectionRect.height > 10 {
                        onSelection(selectionRect)
                    } else {
                        onCancel()
                    }
                }
        )
        .onKeyPress(.escape) {
            onCancel()
            return .handled
        }
        .onAppear {
            // Auto-hide instructions after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if !isSelecting {
                    withAnimation {
                        showInstructions = false
                    }
                }
            }
        }
    }
}

#Preview {
    InteractiveSelectionView(
        screenBounds: CGRect(x: 0, y: 0, width: 1200, height: 800),
        onSelection: { rect in
            print("Selected: \(rect)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}
