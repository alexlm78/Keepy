//
//  TemporaryFileManager.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import Foundation
import AppKit
import Combine

class TemporaryFileManager: ObservableObject {
    static let shared = TemporaryFileManager()

    @Published var files: [TemporaryFile] = []
    private let baseDirectory: URL
    private var cleanupTimer: Timer?

    private init() {
        // Crear directorio dedicado en Application Support
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        baseDirectory = appSupport.appendingPathComponent("Keepy/TempFiles")

        // Crear directorio si no existe
        if !FileManager.default.fileExists(atPath: baseDirectory.path) {
            try? FileManager.default.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        }

        loadFiles()
    }

    func startCleanupScheduler() {
        // Revisar cada 5 minutos
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.cleanupExpiredFiles()
        }

        if let timer = cleanupTimer {
            RunLoop.main.add(timer, forMode: .common)
        }

        // Ejecutar limpieza inmediata al iniciar
        cleanupExpiredFiles()
    }

    func stopCleanupScheduler() {
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }

    func addFile(from sourceURL: URL, policy: TemporaryFile.ExpirationPolicy = .oneDay, tags: [String] = []) throws -> TemporaryFile {
        let fileName = sourceURL.lastPathComponent
        let fileId = UUID().uuidString
        let destinationURL = baseDirectory.appendingPathComponent("\(fileId)_\(fileName)")

        // Copiar archivo
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

        let attributes = try FileManager.default.attributesOfItem(atPath: destinationURL.path)
        let size = attributes[.size] as? Int64 ?? 0

        let tempFile = TemporaryFile(
            id: UUID(),
            name: fileName,
            url: destinationURL,
            size: size,
            createdAt: Date(),
            expirationPolicy: policy,
            tags: tags
        )

        files.append(tempFile)
        saveMetadata()

        return tempFile
    }

    func deleteFile(_ file: TemporaryFile) {
        // Eliminar archivo físico
        try? FileManager.default.removeItem(at: file.url)

        // Eliminar de la lista
        files.removeAll { $0.id == file.id }
        saveMetadata()
    }

    func openFile(_ file: TemporaryFile) {
        NSWorkspace.shared.open(file.url)
    }

    func revealInFinder(_ file: TemporaryFile) {
        NSWorkspace.shared.selectFile(file.url.path, inFileViewerRootedAtPath: "")
    }

    func cleanupExpiredFiles() {
        let expiredFiles = files.filter { $0.isExpired }

        if !expiredFiles.isEmpty {
            expiredFiles.forEach { deleteFile($0) }
        }
    }

    func cleanupSessionFiles() {
        let sessionFiles = files.filter { $0.expirationPolicy == .endOfSession }
        sessionFiles.forEach { deleteFile($0) }
    }

    func updatePolicy(for file: TemporaryFile, newPolicy: TemporaryFile.ExpirationPolicy) {
        if let index = files.firstIndex(where: { $0.id == file.id }) {
            var updatedFile = files[index]
            updatedFile = TemporaryFile(
                id: updatedFile.id,
                name: updatedFile.name,
                url: updatedFile.url,
                size: updatedFile.size,
                createdAt: updatedFile.createdAt,
                expirationPolicy: newPolicy,
                tags: updatedFile.tags
            )
            files[index] = updatedFile
            saveMetadata()
        }
    }

    // MARK: - Persistencia

    private var metadataURL: URL {
        baseDirectory.appendingPathComponent("metadata.json")
    }

    private func saveMetadata() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(files)
            try data.write(to: metadataURL)
        } catch {
            print("Error guardando metadata de archivos temporales: \(error)")
        }
    }

    private func loadFiles() {
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: metadataURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let loadedFiles = try decoder.decode([TemporaryFile].self, from: data)

            // Verificar que los archivos existen
            files = loadedFiles.filter { FileManager.default.fileExists(atPath: $0.url.path) }

            // Guardar para eliminar referencias a archivos que ya no existen
            if files.count != loadedFiles.count {
                saveMetadata()
            }
        } catch {
            print("Error cargando metadata de archivos temporales: \(error)")
        }
    }

    // MARK: - Estadísticas

    var totalSize: Int64 {
        files.reduce(0) { $0 + $1.size }
    }

    var totalSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }

    var expiredCount: Int {
        files.filter { $0.isExpired }.count
    }
}
