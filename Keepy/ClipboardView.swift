//
//  ClipboardView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct ClipboardView: View {
    @State private var searchText = ""

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

            // Placeholder content
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("Historial de Portapapeles")
                        .font(.headline)

                    Text("Aquí aparecerá todo lo que copies")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }

            // Footer
            HStack {
                Text("0 items")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Limpiar Todo") {
                    // TODO: Implementar
                }
                .font(.caption)
                .disabled(true)
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
        }
    }
}

#Preview {
    ClipboardView()
        .frame(width: 400, height: 600)
}
