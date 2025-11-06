//
//  KeepyApp.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI
import AppKit
import Combine

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
    private var languageObserver: AnyCancellable?

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

        // Crear menú contextual
        createMenu()

        // Observer para actualizar menú cuando cambie el idioma
        languageObserver = LocalizationManager.shared.$currentLanguage.sink { [weak self] _ in
            self?.createMenu()
        }

        // Iniciar monitoring de clipboard
        ClipboardManager.shared.startMonitoring()

        // Iniciar scheduler de limpieza de archivos temporales
        TemporaryFileManager.shared.startCleanupScheduler()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Detener monitoring al cerrar
        ClipboardManager.shared.stopMonitoring()

        // Detener scheduler de limpieza
        TemporaryFileManager.shared.stopCleanupScheduler()

        // Limpiar archivos de sesión
        TemporaryFileManager.shared.cleanupSessionFiles()
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
                // Ensure status bar button is not highlighted
                button.isHighlighted = false
            } else {
                // Bring app to front so inputs in the popover receive focus
                // Avoid calling makeKey() here: the status bar's window (NSStatusBarWindow)
                // cannot become key, and forcing it triggers warnings. The popover manages focus.
                NSApp.activate(ignoringOtherApps: true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Remove default highlight around status bar icon
                button.isHighlighted = false
            }
        }
    }

    @objc func openSettings() {
        // Abrir el popover en el tab de configuración
        if let button = statusItem.button {
            if !popover.isShown {
                // Bring app to front so inputs in the popover receive focus
                // Avoid calling makeKey() here: the status bar's window (NSStatusBarWindow)
                // cannot become key, and forcing it triggers warnings. The popover manages focus.
                NSApp.activate(ignoringOtherApps: true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Remove default highlight around status bar icon
                button.isHighlighted = false
            }
            // Enviar notificación para cambiar a tab de configuración
            NotificationCenter.default.post(name: NSNotification.Name("OpenSettings"), object: nil)
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func createMenu() {
        menu = NSMenu()
        
        // Settings item
        let settingsItem = NSMenuItem(
            title: "menu.settings".localized,
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(
            title: "menu.quit".localized,
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }
}
