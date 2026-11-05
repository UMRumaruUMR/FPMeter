//
//  Evaluation.swift
//  FPMeter
//

import Foundation

struct ComplexityResult: Equatable {
    let level: ComplexityLevel
    let unadjustedFP: Int
    let rationale: String
}

struct FPSummary: Equatable {
    let ufp: Int
    let byType: [TransactionType: (count: Int, ufp: Int)]
    let byComplexity: [ComplexityLevel: Int]

    static func empty() -> FPSummary {
        FPSummary(
            ufp: 0,
            byType: Dictionary(uniqueKeysWithValues: TransactionType.allCases.map { ($0, (0, 0)) }),
            byComplexity: Dictionary(uniqueKeysWithValues: ComplexityLevel.allCases.map { ($0, 0) })
        )
    }
}

// Custom Equatable for the tuple-value dictionary
extension FPSummary {
    static func == (lhs: FPSummary, rhs: FPSummary) -> Bool {
        guard lhs.ufp == rhs.ufp else { return false }
        guard lhs.byComplexity == rhs.byComplexity else { return false }
        for key in TransactionType.allCases {
            let l = lhs.byType[key] ?? (0, 0)
            let r = rhs.byType[key] ?? (0, 0)
            if l.count != r.count || l.ufp != r.ufp { return false }
        }
        return true
    }
}

struct ProductivityConfig: Codable, Equatable {
    var low: Int      // conservative: fewer FP per person-month
    var average: Int
    var high: Int     // optimistic: more FP per person-month

    static let industryAverage = ProductivityConfig(low: 5,  average: 8,  high: 15)
    static let experiencedTeam = ProductivityConfig(low: 8,  average: 12, high: 20)
    static let complexDomain   = ProductivityConfig(low: 3,  average: 5,  high: 10)
}

struct MMEstimate: Equatable {
    let low: Double       // optimistic → fewer months
    let average: Double
    let high: Double      // conservative → more months
    let productivityFactor: Int
}
