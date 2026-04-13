//
//  LanguageManager.swift
//  SMSpam
//
//  Created by OpenCode on localization support
//

import Foundation
import SwiftUI

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
        if let saved = UserDefaults.standard.string(forKey: languageKey) {
            self.currentLanguage = saved
        } else {
            let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"
            self.currentLanguage = supportedLanguages.contains { $0.code == deviceLang } ? deviceLang : "en"
        }
    }
    
    func setLanguage(_ code: String) {
        currentLanguage = code
        BundleLanguage.setLanguage(code)
    }
}

class BundleLanguage {
    static var currentLanguage = "en"
    
    static func setLanguage(_ language: String) {
        currentLanguage = language
        UserDefaults.standard.set(language, forKey: "selectedLanguage")
    }
}

func L(_ key: String) -> String {
    let language = BundleLanguage.currentLanguage
    guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
          let bundle = Bundle(path: path) else {
        return key
    }
    return bundle.localizedString(forKey: key, value: key, table: nil)
}

func Lf(_ key: String, _ argument: CVarArg) -> String {
    return String(format: L(key), argument)
}
