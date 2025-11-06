//
//  LocalizationManager.swift
//  Keepy
//
//  Created by Alejandro Lopez Monzon on 5/11/25.
//

import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: Language
    @Published var useSystemLanguage: Bool

    private var bundle: Bundle
    private var localeObserver: NSObjectProtocol?
    private var lastManualLanguage: Language?

    enum Language: String, CaseIterable {
        case english = "en"
        case spanish = "es"

        var displayName: String {
            switch self {
            case .english:
                return "English"
            case .spanish:
                return "Español"
            }
        }
    }

    private init() {
        // Determinar si se debe seguir el idioma del sistema
        let followSystem = UserDefaults.standard.bool(forKey: "UseSystemLanguage")

        // Calcular idioma inicial
        let initialLanguage: Language
        if followSystem {
            initialLanguage = Self.detectSystemLanguage()
        } else if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage"),
                  let language = Language(rawValue: savedLanguage) {
            initialLanguage = language
        } else {
            initialLanguage = Self.detectSystemLanguage()
        }

        // Inicializar propiedades
        self.currentLanguage = initialLanguage
        self.useSystemLanguage = followSystem
        self.bundle = Self.loadBundle(for: initialLanguage)
        if let savedManual = UserDefaults.standard.string(forKey: "LastManualLanguage"),
           let manualLang = Language(rawValue: savedManual) {
            self.lastManualLanguage = manualLang
        } else {
            self.lastManualLanguage = nil
        }

        // Observar cambios de idioma del sistema cuando esté habilitado seguir sistema
        localeObserver = NotificationCenter.default.addObserver(
            forName: NSLocale.currentLocaleDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            if self.useSystemLanguage {
                let detected = Self.detectSystemLanguage()
                self.currentLanguage = detected
                self.bundle = Self.loadBundle(for: detected)
            }
        }
    }
    
    private static func detectSystemLanguage() -> Language {
        // Obtener los idiomas preferidos del sistema
        let preferredLanguages = Locale.preferredLanguages
        
        // Primero intentar con el idioma principal
        if let primaryLanguage = preferredLanguages.first {
            let languageCode = String(primaryLanguage.prefix(2))
            
            // Verificar si tenemos soporte para este idioma
            if let supportedLanguage = Language(rawValue: languageCode) {
                return supportedLanguage
            }
            
            // Para español, también verificar variaciones (es-ES, es-MX, etc.)
            if languageCode == "es" || primaryLanguage.hasPrefix("es-") {
                return .spanish
            }
        }
        
        // Fallback al idioma actual del sistema
        let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        return Language(rawValue: systemLanguage) ?? .english
    }

    private static func loadBundle(for language: Language) -> Bundle {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return Bundle.main
        }
        return bundle
    }

    func localized(_ key: String) -> String {
        // Usar explícitamente la tabla "Localizable".
        let value = bundle.localizedString(forKey: key, value: nil, table: "Localizable")
        // Fallback adicional al bundle principal si no se encontró.
        if value == key {
            return Bundle.main.localizedString(forKey: key, value: nil, table: "Localizable")
        }
        return value
    }
    
    // Método para obtener el idioma actual
    func getCurrentLanguage() -> Language {
        return currentLanguage
    }
    
    // Método para cambiar idioma y notificar
    func setLanguage(_ language: Language) {
        // Desactivar seguimiento del sistema al seleccionar manualmente
        useSystemLanguage = false
        UserDefaults.standard.set(false, forKey: "UseSystemLanguage")

        currentLanguage = language
        bundle = LocalizationManager.loadBundle(for: language)
        UserDefaults.standard.set(language.rawValue, forKey: "AppLanguage")
        lastManualLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "LastManualLanguage")
    }
    
    // Método para obtener todos los idiomas disponibles
    static func availableLanguages() -> [Language] {
        return Language.allCases
    }
    
    // Método para resetear al idioma del sistema
    func resetToSystemLanguage() {
        enableSystemLanguage()
    }

    func enableSystemLanguage() {
        useSystemLanguage = true
        UserDefaults.standard.set(true, forKey: "UseSystemLanguage")

        let detected = Self.detectSystemLanguage()
        currentLanguage = detected
        bundle = LocalizationManager.loadBundle(for: detected)
    }

    func disableSystemLanguage() {
        useSystemLanguage = false
        UserDefaults.standard.set(false, forKey: "UseSystemLanguage")
        // Restaurar último idioma manual si existe, en caso contrario detectar sistema
        let targetLanguage = lastManualLanguage ?? Self.detectSystemLanguage()
        currentLanguage = targetLanguage
        bundle = LocalizationManager.loadBundle(for: targetLanguage)
        UserDefaults.standard.set(targetLanguage.rawValue, forKey: "AppLanguage")
    }

    // Exponer el idioma del sistema detectado para diagnóstico
    func getDetectedSystemLanguage() -> Language {
        return Self.detectSystemLanguage()
    }
}

// Extension para hacer más fácil la localización
extension String {
    var localized: String {
        return LocalizationManager.shared.localized(self)
    }

    func localized(_ args: CVarArg...) -> String {
        return String(format: localized, arguments: args)
    }
}
