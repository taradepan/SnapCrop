import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide Dock and app switcher
        NSApp.setActivationPolicy(.accessory)
        
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(named: NSImage.actionTemplateName)
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }
        
        // Add a menu with a Quit item
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open SnapCrop", action: #selector(statusBarButtonClicked), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit SnapCrop", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func statusBarButtonClicked() {
        // If window is visible, hide it
        if let window = window, window.isVisible {
            window.orderOut(nil)
            return
        }
        // Create window if needed
        if window == nil {
            let contentView = ContentView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.setFrameAutosaveName("MainWindow")
            window.contentView = NSHostingView(rootView: contentView)
            window.title = "SnapCrop"
            window.isReleasedWhenClosed = false // Don't deallocate on close
            self.window = window
        }
        // Position window under menu bar icon
        if let window = window, let button = statusItem?.button, let screen = NSScreen.main {
            let buttonRect = button.window?.convertToScreen(button.frame) ?? .zero
            let windowWidth = window.frame.width
            let windowHeight = window.frame.height
            let x = buttonRect.origin.x + (buttonRect.width - windowWidth) / 2
            let y = screen.frame.maxY - windowHeight - (buttonRect.origin.y - screen.frame.origin.y)
            window.setFrameOrigin(NSPoint(x: x, y: y))
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
} 