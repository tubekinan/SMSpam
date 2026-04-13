//
//  LanguageManager.swift
//  SMSpam
//
//  Created by OpenCode on localization support
//

import Foundation
import SwiftUI
import Combine

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
        }
    }
    
    private let languageKey = "selectedLanguage"
    
    let supportedLanguages: [(code: String, name: String, nativeName: String)] = [
        ("tr", "Turkish", "Türkçe"),
        ("en", "English", "English"),
        ("de", "German", "Deutsch"),
        ("fr", "French", "Français"),
        ("es", "Spanish", "Español"),
        ("zh-Hans", "Chinese", "中文"),
        ("ja", "Japanese", "日本語"),
        ("ku", "Kurdish", "Kurdî")
    ]
    
    init() {
        self.currentLanguage = BundleLanguage.currentLanguage
    }
    
    func setLanguage(_ code: String) {
        currentLanguage = code
        Localization.setLanguage(code)
    }
}

enum Localization {
    static func setLanguage(_ language: String) {
        BundleLanguage.currentLanguage = language
    }
    
    static func local(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: BundleLanguage.currentLanguage, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}

class BundleLanguage {
    private static let languageKey = "selectedLanguage"
    
    static var currentLanguage: String {
        get {
            if let saved = UserDefaults.standard.string(forKey: languageKey) {
                return saved
            }
            let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"
            return BundleLanguage.supportedLanguageCodes.contains(deviceLang) ? deviceLang : "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: languageKey)
        }
    }
    
    static let supportedLanguageCodes = [
        "tr", "en", "de", "fr", "es", "zh-Hans", "ja", "ku"
    ]
}

func L(_ key: String) -> String {
    return Localization.local(key)
}

func Lf(_ key: String, _ argument: CVarArg) -> String {
    return String(format: L(key), argument)
}
