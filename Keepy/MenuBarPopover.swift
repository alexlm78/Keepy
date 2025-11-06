//
//  MenuBarPopover.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct MenuBarPopover: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header con tabs
            HStack(spacing: 0) {
                TabButton(icon: "doc.on.clipboard", title: "Clipboard", tag: 0, selectedTab: $selectedTab)
                TabButton(icon: "folder", title: "Archivos", tag: 1, selectedTab: $selectedTab)
                TabButton(icon: "note.text", title: "Notas", tag: 2, selectedTab: $selectedTab)
                TabButton(icon: "gearshape", title: "Config", tag: 3, selectedTab: $selectedTab)
            }
            .frame(height: 40)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Content
            Group {
                switch selectedTab {
                case 0:
                    ClipboardView()
                case 1:
                    TemporaryFilesView()
                case 2:
                    NotesView()
                case 3:
                    SettingsView()
                default:
                    ClipboardView()
                }
            }
        }
        .frame(width: 400, height: 600)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenSettings"))) { _ in
            selectedTab = 3
        }
    }
}

struct TabButton: View {
    let icon: String
    let title: String
    let tag: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: { selectedTab = tag }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 10))
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(selectedTab == tag ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MenuBarPopover()
}
