//
//  ClipboardItem.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import Foundation
import AppKit

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
    let contentType: ContentType
    let timestamp: Date
    var isFavorite: Bool
    let imageData: Data?
    let fileURL: URL?

    enum ContentType: String, Codable {
        case text
        case image
        case file
        case url
    }

    var preview: String {
        switch contentType {
        case .text:
            return String(content.prefix(100))
        case .url:
            return content
        case .image:
            return "🖼️ Imagen"
        case .file:
            return "📄 \(fileURL?.lastPathComponent ?? "Archivo")"
        }
    }

    var icon: String {
        switch contentType {
        case .text:
            return "doc.text"
        case .url:
            return "link"
        case .image:
            return "photo"
        case .file:
            return "doc"
        }
    }

    // Inicializador para texto/URL
    init(id: UUID = UUID(), content: String, contentType: ContentType, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.content = content
        self.contentType = contentType
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.imageData = nil
        self.fileURL = nil
    }

    // Inicializador para imágenes
    init(id: UUID = UUID(), imageData: Data, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.content = ""
        self.contentType = .image
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.imageData = imageData
        self.fileURL = nil
    }

    // Inicializador para archivos
    init(id: UUID = UUID(), fileURL: URL, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.content = fileURL.path
        self.contentType = .file
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.imageData = nil
        self.fileURL = fileURL
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            return match.range.length == self.utf16.count
        }
        return false
    }
}
