//
//  EditingToolsView.swift
//  SnapCrop
//
//  Created by taradepan on 2025-06-21.
//

import SwiftUI

struct EditingToolsView: View {
    @ObservedObject var viewModel: EditingViewModel
    @Binding var canvasSize: CGSize
    var onNewCapture: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // New Capture Button
                Button(action: onNewCapture) {
                    Label("New Capture", systemImage: "camera.badge.ellipsis")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .controlSize(.large)
                .padding(.bottom)

                // Controls
                Group {
                    Text("Padding").font(.headline)
                    Slider(value: $viewModel.gradientPadding, in: 0...200)
                    
                    Text("Corner Radius").font(.headline)
                    Slider(value: $viewModel.screenshotCornerRadius, in: 0...100)
                    
                    Text("Background Radius").font(.headline)
                    Slider(value: $viewModel.gradientCornerRadius, in: 0...110)
                }
                
                Divider()

                Group {
                    Text("Shadow").font(.headline)
                    Toggle("Show Shadow", isOn: $viewModel.showShadow)
                    
                    Text("Opacity")
                    Slider(value: $viewModel.shadowOpacity, in: 0...1)
                    
                    Text("Radius")
                    Slider(value: $viewModel.shadowRadius, in: 0...100)
                    
                    Text("Position (Y)")
                    Slider(value: $viewModel.shadowYOffset, in: -50...50)
                }
                
                Divider()
                
                Text("Gradient").font(.headline)
                GradientPicker(selection: $viewModel.activeGradient)
                Toggle("Show Gradient Background", isOn: $viewModel.showGradient)
                
                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.copyToClipboard(canvasSize)
                    }) {
                        Label("Copy Image", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    
                    Button(action: {
                        viewModel.saveToFile(canvasSize)
                    }) {
                        Label("Export Image", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .padding(.top)

            }
            .padding()
        }
        .frame(width: 320)
        .background(.regularMaterial)
    }
} 