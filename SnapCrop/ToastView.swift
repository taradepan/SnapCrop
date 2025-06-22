import SwiftUI

enum ToastStyle {
    case success, error, info, warning
    
    var themeColor: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}

struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 2
}

struct ToastView: View {
    let toast: Toast
    var onCancel: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.style.iconName)
                .foregroundColor(toast.style.themeColor)
                .font(.title2)
            Text(toast.message)
                .font(.headline)
                .foregroundColor(.primary)
            if let onCancel = onCancel {
                Spacer(minLength: 10)
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 32)
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1000)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if let toast = toast {
                VStack {
                    ToastView(toast: toast) {
                        dismissToast()
                    }
                    Spacer()
                }
                .onAppear { showToast() }
                .animation(.spring(), value: toast)
            }
        }
    }
    
    private func showToast() {
        guard let toast = toast else { return }
        workItem?.cancel()
        let task = DispatchWorkItem { dismissToast() }
        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
    }
    
    private func dismissToast() {
        withAnimation { toast = nil }
        workItem?.cancel()
        workItem = nil
    }
}

extension View {
    func toast(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
} 