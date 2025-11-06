//
//  TemporaryFilesView.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct TemporaryFilesView: View {
    @ObservedObject private var manager = TemporaryFileManager.shared
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var isDragging = false
    @State private var showingFilePicker = false
    @State private var selectedPolicy: TemporaryFile.ExpirationPolicy = .oneDay

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("files.title".localized)
                    .font(.headline)

                Spacer()

                Button(action: { showingFilePicker = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // Content
            if manager.files.isEmpty {
                // Empty state with drop zone
                VStack(spacing: 16) {
                    Image(systemName: "folder")
                        .font(.system(size: 48))
                        .foregroundColor(isDragging ? .accentColor : .secondary)

                    Text("files.empty".localized)
                        .font(.headline)

                    Text("files.emptyDescription".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isDragging ? Color.accentColor.opacity(0.1) : Color.clear)
                .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                }
            } else {
                // List of files
                ScrollView {
                    LazyVStack(spacing: 1) {
                        ForEach(manager.files) { file in
                            TemporaryFileRow(file: file)
                                .contextMenu {
                                    Button(action: { manager.openFile(file) }) {
                                        Label("files.open".localized, systemImage: "arrow.up.forward.app")
                                    }

                                    Button(action: { manager.revealInFinder(file) }) {
                                        Label("files.reveal".localized, systemImage: "folder")
                                    }

                                    Divider()

                                    Menu("Change Policy") {
                                        ForEach(TemporaryFile.ExpirationPolicy.allCases, id: \.self) { policy in
                                            Button(policy.localizedName) {
                                                manager.updatePolicy(for: file, newPolicy: policy)
                                            }
                                        }
                                    }

                                    Divider()

                                    Button(role: .destructive, action: { manager.deleteFile(file) }) {
                                        Label("clipboard.delete".localized, systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .background(Color.clear)
                .onDrop(of: [.fileURL], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                }
            }

            // Footer
            HStack {
                Text("\(manager.files.count) \("files.count".localized) · \(manager.totalSizeFormatted)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if manager.expiredCount > 0 {
                    Button("files.cleanExpired".localized + " (\(manager.expiredCount))") {
                        manager.cleanupExpiredFiles()
                    }
                    .font(.caption)
                }
            }
            .padding(8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .id(localization.currentLanguage)
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    _ = try? manager.addFile(from: url, policy: selectedPolicy)
                }
            case .failure(let error):
                print("Error selecting file: \(error)")
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }

                DispatchQueue.main.async {
                    _ = try? manager.addFile(from: url, policy: .oneDay)
                }
            }
        }
        return true
    }
}

struct TemporaryFileRow: View {
    let file: TemporaryFile

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Icon
            Image(systemName: file.icon)
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                // Filename
                Text(file.name)
                    .font(.system(size: 12))
                    .lineLimit(1)

                // Info
                HStack(spacing: 8) {
                    Text(file.sizeFormatted)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("·")
                        .foregroundColor(.secondary)

                    if file.isExpired {
                        Text("files.expired".localized)
                            .font(.caption2)
                            .foregroundColor(.red)
                    } else if let timeRemaining = file.timeRemaining {
                        Text("\("files.expires".localized): \(timeRemaining)")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Text(file.expirationPolicy.localizedName)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Extension badge
            Text(file.fileExtension)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.accentColor)
                .cornerRadius(4)
        }
        .padding(8)
        .background(file.isExpired ? Color.red.opacity(0.1) : Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(4)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
}

#Preview {
    TemporaryFilesView()
        .frame(width: 400, height: 600)
}
