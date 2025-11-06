//
//  SettingsView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var maxClipboardItems = 1000
    @State private var defaultFileExpiration = 1
    @State private var launchAtLogin = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.accentColor)

                    VStack(alignment: .leading) {
                        Text("Configuración")
                            .font(.title2)
                            .bold()
                        Text("Keepy v1.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)

                Divider()

                // Clipboard settings
                VStack(alignment: .leading, spacing: 12) {
                    Label("Portapapeles", systemImage: "doc.on.clipboard")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Máximo de items en historial:")
                            .font(.subheadline)

                        Picker("", selection: $maxClipboardItems) {
                            Text("100").tag(100)
                            Text("500").tag(500)
                            Text("1000").tag(1000)
                            Text("5000").tag(5000)
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Divider()

                // File settings
                VStack(alignment: .leading, spacing: 12) {
                    Label("Archivos Temporales", systemImage: "folder")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Política de expiración por defecto:")
                            .font(.subheadline)

                        Picker("", selection: $defaultFileExpiration) {
                            Text("Fin de sesión").tag(0)
                            Text("1 hora").tag(1)
                            Text("1 día").tag(2)
                            Text("1 semana").tag(3)
                            Text("Manual").tag(4)
                        }
                        .pickerStyle(.menu)
                    }
                }

                Divider()

                // General settings
                VStack(alignment: .leading, spacing: 12) {
                    Label("General", systemImage: "gearshape")
                        .font(.headline)

                    Toggle("Iniciar al arrancar el sistema", isOn: $launchAtLogin)
                        .font(.subheadline)
                }

                Divider()

                // About section
                VStack(alignment: .leading, spacing: 8) {
                    Label("Acerca de", systemImage: "info.circle")
                        .font(.headline)

                    Text("Keepy es una utilidad de portapapeles, archivos temporales y notas rápidas para macOS.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Button("Ayuda") {
                            // TODO: Abrir ayuda
                        }
                        .font(.caption)

                        Button("GitHub") {
                            // TODO: Abrir repositorio
                        }
                        .font(.caption)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
        .frame(width: 400, height: 600)
}
