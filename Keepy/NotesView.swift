//
//  NotesView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct NotesView: View {
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header con búsqueda
            VStack(spacing: 8) {
                HStack {
                    Text("Notas Rápidas")
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
                    TextField("Buscar notas...", text: $searchText)
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

                    Text("No hay notas")
                        .font(.headline)

                    Text("Crea tu primera nota rápida")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }

            // Footer
            HStack {
                Text("0 notas")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
}

#Preview {
    NotesView()
        .frame(width: 400, height: 600)
}
