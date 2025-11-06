//
//  KeepyApp.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI
import AppKit

@main
struct KeepyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No WindowGroup - solo Settings para conformar con App protocol
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Crear status item en menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Keepy")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Configurar popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarPopover())

        // Iniciar monitoring de clipboard
        ClipboardManager.shared.startMonitoring()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Detener monitoring al cerrar
        ClipboardManager.shared.stopMonitoring()
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}
