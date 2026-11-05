//
//  HapticsService.swift
//  FPMeter
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum HapticsService {

    static func complexityChanged(_ level: ComplexityLevel, enabled: Bool) {
        guard enabled else { return }
        #if canImport(UIKit)
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        switch level {
        case .low:     style = .light
        case .average: style = .medium
        case .high:    style = .heavy
        }
        let g = UIImpactFeedbackGenerator(style: style)
        g.impactOccurred()
        #endif
    }

    static func selection(enabled: Bool) {
        guard enabled else { return }
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    static func success(enabled: Bool) {
        guard enabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func warning(enabled: Bool) {
        guard enabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }
}
