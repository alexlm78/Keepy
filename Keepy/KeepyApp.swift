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
    var menu: NSMenu!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Crear status item en menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(named: "MenuBarIcon")
            button.image?.isTemplate = true  // Ensure template rendering
            button.action = #selector(statusItemClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Configurar popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 600)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: MenuBarPopover())

        // Crear menú contextual (para click derecho)
        menu = NSMenu()

        let settingsItem = NSMenuItem(title: "Configuración", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Salir de Keepy", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        // Iniciar monitoring de clipboard
        ClipboardManager.shared.startMonitoring()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Detener monitoring al cerrar
        ClipboardManager.shared.stopMonitoring()
    }

    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            // Click derecho: mostrar menú
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil
        } else {
            // Click izquierdo: toggle popover
            togglePopover()
        }
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

    @objc func openSettings() {
        // Abrir el popover en el tab de configuración
        if let button = statusItem.button {
            if !popover.isShown {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
            // Enviar notificación para cambiar a tab de configuración
            NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
