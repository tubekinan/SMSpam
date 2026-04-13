//
//  SMSpamApp.swift
//  SMSpam
//
//  Created by Inan Tubek on 19.03.2026.
//

import SwiftUI

@main
struct SMSpamApp: App {
    init() {
        _ = BundleLanguage.currentLanguage
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
