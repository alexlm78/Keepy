//
//  ClipboardManager.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import AppKit
import Combine

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()

    @Published var items: [ClipboardItem] = []
    private var changeCount: Int = 0
    private var timer: Timer?
    private let maxItems = 1000

    private init() {
        loadFromDisk()
    }

    func startMonitoring() {
        changeCount = NSPasteboard.general.changeCount

        // Polling cada 0.5 segundos
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkForChanges()
        }

        // Agregar al main run loop para asegurar que se ejecuta incluso cuando el popover está abierto
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkForChanges() {
        let currentChangeCount = NSPasteboard.general.changeCount

        if currentChangeCount != changeCount {
            changeCount = currentChangeCount
            captureClipboard()
        }
    }

    private func captureClipboard() {
        let pasteboard = NSPasteboard.general

        // Prioridad: imagen > archivo > texto/URL
        if let imageData = getImageData(from: pasteboard) {
            let item = ClipboardItem(imageData: imageData)
            addItem(item)
        } else if let fileURLString = pasteboard.string(forType: .fileURL),
                  let fileURL = URL(string: fileURLString) {
            let item = ClipboardItem(fileURL: fileURL)
            addItem(item)
        } else if let string = pasteboard.string(forType: .string), !string.isEmpty {
            let contentType: ClipboardItem.ContentType = string.isValidURL ? .url : .text
            let item = ClipboardItem(content: string, contentType: contentType)
            addItem(item)
        }
    }

    private func getImageData(from pasteboard: NSPasteboard) -> Data? {
        // Intentar PNG primero, luego TIFF
        if let pngData = pasteboard.data(forType: .png) {
            return pngData
        } else if let tiffData = pasteboard.data(forType: .tiff) {
            // Convertir TIFF a PNG para consistencia
            if let imageRep = NSBitmapImageRep(data: tiffData),
               let pngData = imageRep.representation(using: .png, properties: [:]) {
                return pngData
            }
        }
        return nil
    }

    private func addItem(_ item: ClipboardItem) {
        // Evitar duplicados consecutivos
        if let lastItem = items.first {
            if lastItem.contentType == item.contentType {
                switch item.contentType {
                case .text, .url:
                    if lastItem.content == item.content {
                        return
                    }
                case .image:
                    if lastItem.imageData == item.imageData {
                        return
                    }
                case .file:
                    if lastItem.fileURL == item.fileURL {
                        return
                    }
                }
            }
        }

        items.insert(item, at: 0)

        // Mantener límite
        if items.count > maxItems {
            items.removeLast()
        }

        saveToDisk()
    }

    func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.contentType {
        case .text, .url:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let imageData = item.imageData {
                pasteboard.setData(imageData, forType: .png)
            }
        case .file:
            if let fileURL = item.fileURL {
                pasteboard.setString(fileURL.path, forType: .fileURL)
            }
        }

        // Actualizar changeCount para evitar re-capturar lo que acabamos de copiar
        changeCount = NSPasteboard.general.changeCount
    }

    func toggleFavorite(_ item: ClipboardItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
            saveToDisk()
        }
    }

    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveToDisk()
    }

    func clearHistory() {
        items.removeAll()
        saveToDisk()
    }

    // MARK: - Persistencia

    private var storageURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let keepyDir = appSupport.appendingPathComponent("Keepy")

        // Crear directorio si no existe
        if !FileManager.default.fileExists(atPath: keepyDir.path) {
            try? FileManager.default.createDirectory(at: keepyDir, withIntermediateDirectories: true)
        }

        return keepyDir.appendingPathComponent("clipboard_history.json")
    }

    private func saveToDisk() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(items)
            try data.write(to: storageURL)
        } catch {
            print("Error guardando historial: \(error)")
        }
    }

    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            items = try decoder.decode([ClipboardItem].self, from: data)
        } catch {
            print("Error cargando historial: \(error)")
        }
    }
}
