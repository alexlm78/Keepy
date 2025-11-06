//
//  ClipboardView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct ClipboardView: View {
    @ObservedObject private var manager = ClipboardManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
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
                TextField("clipboard.search".localized, text: $searchText)
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

                        Text(searchText.isEmpty ? "clipboard.title".localized : "clipboard.noResults".localized)
                            .font(.headline)

                        Text(searchText.isEmpty ? "clipboard.empty".localized : "clipboard.tryAgain".localized)
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
                                        Label("clipboard.copy".localized, systemImage: "doc.on.doc")
                                    }

                                    Button(action: { manager.toggleFavorite(item) }) {
                                        Label(
                                            item.isFavorite ? "clipboard.unfavorite".localized : "clipboard.favorite".localized,
                                            systemImage: item.isFavorite ? "star.slash" : "star"
                                        )
                                    }

                                    Divider()

                                    Button(role: .destructive, action: { manager.deleteItem(item) }) {
                                        Label("clipboard.delete".localized, systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }

            // Footer
            HStack {
                Text("\(filteredItems.count) \("clipboard.items".localized)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("clipboard.clearAll".localized) {
                    showingClearAlert = true
                }
                .font(.caption)
                .disabled(manager.items.isEmpty)
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .id(localization.currentLanguage)
        .alert("clipboard.clearConfirm.title".localized, isPresented: $showingClearAlert) {
            Button("clipboard.cancel".localized, role: .cancel) { }
            Button("clipboard.clear".localized, role: .destructive) {
                manager.clearHistory()
            }
        } message: {
            Text("clipboard.clearConfirm.message".localized)
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
