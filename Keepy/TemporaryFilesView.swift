//
//  TemporaryFilesView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct TemporaryFilesView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Archivos Temporales")
                    .font(.headline)

                Spacer()

                Button(action: {
                    // TODO: Implementar agregar archivo
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Placeholder content
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "folder")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No hay archivos temporales")
                        .font(.headline)

                    Text("Arrastra archivos aquí o usa el botón +")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }

            // Footer
            HStack {
                Text("0 archivos")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Limpiar Expirados") {
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
    TemporaryFilesView()
        .frame(width: 400, height: 600)
}
