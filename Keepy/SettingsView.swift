//
//  SettingsView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var localization = LocalizationManager.shared
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
                        Text("settings.title".localized)
                            .font(.title2)
                            .bold()
                        Text("settings.version".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)

                Divider()

                // Clipboard settings
                VStack(alignment: .leading, spacing: 12) {
                    Label("settings.clipboard".localized, systemImage: "doc.on.clipboard")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("settings.clipboard.maxItems".localized)
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
                    Label("settings.files".localized, systemImage: "folder")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("settings.files.defaultPolicy".localized)
                            .font(.subheadline)

                        Picker("", selection: $defaultFileExpiration) {
                            Text("files.policy.session".localized).tag(0)
                            Text("files.policy.oneHour".localized).tag(1)
                            Text("files.policy.oneDay".localized).tag(2)
                            Text("files.policy.oneWeek".localized).tag(3)
                            Text("files.policy.manual".localized).tag(4)
                        }
                        .pickerStyle(.menu)
                    }
                }

                Divider()

                // General settings
                VStack(alignment: .leading, spacing: 12) {
                    Label("settings.general".localized, systemImage: "gearshape")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("settings.general.language".localized)
                            .font(.subheadline)

                        Toggle("settings.general.useSystemLanguage".localized, isOn: Binding(
                            get: { localization.useSystemLanguage },
                            set: { newValue in
                                if newValue {
                                    localization.enableSystemLanguage()
                                } else {
                                    localization.disableSystemLanguage()
                                }
                            }
                        ))
                        .font(.subheadline)

                        Picker("", selection: Binding(
                            get: { localization.currentLanguage },
                            set: { newLang in localization.setLanguage(newLang) }
                        )) {
                            ForEach(LocalizationManager.Language.allCases, id: \.self) { language in
                                Text(language.displayName).tag(language)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: 200)
                        .disabled(localization.useSystemLanguage)
                    }

                    Toggle("settings.general.launchAtLogin".localized, isOn: $launchAtLogin)
                        .font(.subheadline)
                }

                Divider()

                // About section
                VStack(alignment: .leading, spacing: 8) {
                    Label("settings.about".localized, systemImage: "info.circle")
                        .font(.headline)

                    Text("settings.about.description".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Button("settings.help".localized) {
                            // TODO: Abrir ayuda
                        }
                        .font(.caption)

                        Button("settings.github".localized) {
                            // TODO: Abrir repositorio
                        }
                        .font(.caption)
                    }
                }

                Divider()

                // Localization diagnostics
                /*VStack(alignment: .leading, spacing: 8) {
                    Label("settings.diagnostics".localized, systemImage: "globe")
                        .font(.headline)

                    HStack {
                        Text("settings.diagnostics.currentLanguage".localized)
                            .font(.subheadline)
                        Spacer()
                        Text(localization.currentLanguage.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("settings.diagnostics.systemMode".localized)
                            .font(.subheadline)
                        Spacer()
                        Text(localization.useSystemLanguage ? "settings.diagnostics.enabled".localized : "settings.diagnostics.disabled".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("settings.diagnostics.detectedLanguage".localized)
                            .font(.subheadline)
                        Spacer()
                        Text(localization.getDetectedSystemLanguage().displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("settings.diagnostics.key".localized).bold()
                            Spacer()
                            Text("settings.diagnostics.value".localized).bold()
                        }
                        HStack {
                            Text("menu.settings")
                            Spacer()
                            Text("menu.settings".localized)
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("menu.quit")
                            Spacer()
                            Text("menu.quit".localized)
                                .foregroundColor(.secondary)
                        }
                    }
                }*/

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
