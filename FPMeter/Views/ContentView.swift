//
//  ContentView.swift
//  FPMeter
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var languageOverride: String? = nil

    var body: some View {
        DashboardView()
            .environmentObject(appState)
            .environment(\.locale, resolvedLocale)
            .onAppear { applyLanguage() }
            .onChange(of: appState.settings.language) { _ in applyLanguage() }
    }

    private var resolvedLocale: Locale {
        switch appState.settings.language {
        case .system: return Locale.current
        case .en: return Locale(identifier: "en")
        case .ko: return Locale(identifier: "ko")
        case .ja: return Locale(identifier: "ja")
        }
    }

    private func applyLanguage() {
        let lang: String
        switch appState.settings.language {
        case .system:
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            return
        case .en: lang = "en"
        case .ko: lang = "ko"
        case .ja: lang = "ja"
        }
        UserDefaults.standard.set([lang], forKey: "AppleLanguages")
    }
}

#Preview {
    ContentView()
}
