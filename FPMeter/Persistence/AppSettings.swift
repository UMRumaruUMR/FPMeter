//
//  AppSettings.swift
//  FPMeter
//

import Foundation

enum LanguagePreference: String, Codable, CaseIterable, Identifiable {
    case system
    case en
    case ko
    case ja

    var id: String { rawValue }
}

struct AppSettings: Codable, Equatable {
    var productivity: ProductivityConfig = .industryAverage
    var useVAF: Bool = true
    var language: LanguagePreference = .system
    var hapticsEnabled: Bool = true
    var quickAddEnabled: Bool = true
}
