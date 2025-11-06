//
//  NotesView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct NotesView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header con búsqueda
            VStack(spacing: 8) {
                HStack {
                    Text("notes.title".localized)
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        // TODO: Implementar nueva nota
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.plain)
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("notes.search".localized, text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Placeholder content
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("notes.empty".localized)
                        .font(.headline)

                    Text("notes.emptyDescription".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }

            // Footer
            HStack {
                Text("0 \("notes.count".localized)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .id(localization.currentLanguage)
    }
}

#Preview {
    NotesView()
        .frame(width: 400, height: 600)
}
