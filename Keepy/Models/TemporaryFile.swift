//
//  TemporaryFile.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import Foundation

struct TemporaryFile: Identifiable, Codable {
    let id: UUID
    let name: String
    let url: URL
    let size: Int64
    let createdAt: Date
    let expirationPolicy: ExpirationPolicy
    var tags: [String]

    enum ExpirationPolicy: String, Codable, CaseIterable {
        case endOfSession
        case oneHour
        case oneDay
        case oneWeek
        case manual

        var localizedName: String {
            switch self {
            case .endOfSession:
                return "files.policy.session".localized
            case .oneHour:
                return "files.policy.oneHour".localized
            case .oneDay:
                return "files.policy.oneDay".localized
            case .oneWeek:
                return "files.policy.oneWeek".localized
            case .manual:
                return "files.policy.manual".localized
            }
        }

        var duration: TimeInterval? {
            switch self {
            case .endOfSession, .manual:
                return nil
            case .oneHour:
                return 3600
            case .oneDay:
                return 86400
            case .oneWeek:
                return 604800
            }
        }
    }

    var sizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }

    var expiresAt: Date? {
        guard let duration = expirationPolicy.duration else {
            return nil
        }
        return createdAt.addingTimeInterval(duration)
    }

    var isExpired: Bool {
        guard let expiresAt = expiresAt else {
            return false
        }
        return Date() > expiresAt
    }

    var timeRemaining: String? {
        guard let expiresAt = expiresAt, !isExpired else {
            return nil
        }

        let interval = expiresAt.timeIntervalSinceNow
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)

        if hours > 24 {
            let days = hours / 24
            return "\(days)d"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var fileExtension: String {
        url.pathExtension.uppercased()
    }

    var icon: String {
        let ext = url.pathExtension.lowercased()

        switch ext {
        case "pdf":
            return "doc.richtext"
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo"
        case "mp4", "mov", "avi":
            return "video"
        case "mp3", "m4a", "wav":
            return "music.note"
        case "zip", "rar", "7z":
            return "archivebox"
        case "txt", "md":
            return "doc.text"
        case "doc", "docx":
            return "doc"
        case "xls", "xlsx":
            return "tablecells"
        case "ppt", "pptx":
            return "square.grid.3x3.square"
        default:
            return "doc"
        }
    }
}
