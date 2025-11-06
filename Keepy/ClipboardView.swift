//
//  ClipboardView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct ClipboardView: View {
    @ObservedObject private var manager = ClipboardManager.shared
    @State private var searchText = ""
    @State private var showingClearAlert = false

    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return manager.items
        }
        return manager.items.filter { item in
            item.content.localizedCaseInsensitiveContains(searchText) ||
            item.preview.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Buscar...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Content
            if filteredItems.isEmpty {
                // Empty state
                ScrollView {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.on.clipboard")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text(searchText.isEmpty ? "Historial de Portapapeles" : "No se encontraron resultados")
                            .font(.headline)

                        Text(searchText.isEmpty ? "Aquí aparecerá todo lo que copies" : "Intenta con otra búsqueda")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                }
            } else {
                // List of items
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(filteredItems) { item in
                            ClipboardItemRow(item: item)
                                .onTapGesture {
                                    manager.copyToClipboard(item)
                                }
                                .contextMenu {
                                    Button(action: { manager.copyToClipboard(item) }) {
                                        Label("Copiar", systemImage: "doc.on.doc")
                                    }

                                    Button(action: { manager.toggleFavorite(item) }) {
                                        Label(
                                            item.isFavorite ? "Quitar favorito" : "Marcar favorito",
                                            systemImage: item.isFavorite ? "star.slash" : "star"
                                        )
                                    }

                                    Divider()

                                    Button(role: .destructive, action: { manager.deleteItem(item) }) {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }

            // Footer
            HStack {
                Text("\(filteredItems.count) items")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Limpiar Todo") {
                    showingClearAlert = true
                }
                .font(.caption)
                .disabled(manager.items.isEmpty)
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .alert("Limpiar Historial", isPresented: $showingClearAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Limpiar", role: .destructive) {
                manager.clearHistory()
            }
        } message: {
            Text("¿Estás seguro que quieres eliminar todo el historial del portapapeles?")
        }
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Icon
            Image(systemName: item.icon)
                .foregroundColor(.secondary)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                // Preview content
                if item.contentType == .image, let imageData = item.imageData, let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 100)
                        .cornerRadius(4)
                } else {
                    Text(item.preview)
                        .lineLimit(3)
                        .font(.system(size: 12))
                }

                // Timestamp
                Text(item.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Favorite indicator
            if item.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
        .padding(8)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(4)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}

#Preview {
    ClipboardView()
        .frame(width: 400, height: 600)
}
