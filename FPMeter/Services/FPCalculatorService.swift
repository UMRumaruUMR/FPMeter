//
//  FPCalculatorService.swift
//  FPMeter
//

import Foundation

enum FPCalculatorService {

    /// VAF = 0.65 + (0.01 × Σ GSC_i), each GSC 0–5.
    /// Clamped to [0.65, 1.35].
    static func calculateVAF(gscValues: [Int]) -> Double {
        let sum = gscValues.reduce(0, +)
        let raw = 0.65 + 0.01 * Double(sum)
        return (raw * 10000).rounded() / 10000
    }

    /// AFP = UFP × VAF
    static func calculateAFP(ufp: Int, vaf: Double) -> Double {
        let raw = Double(ufp) * vaf
        return (raw * 100).rounded() / 100
    }

    /// Summarize a list of transactions into totals by type and complexity.
    static func summarize(_ transactions: [Transaction]) -> FPSummary {
        var byType: [TransactionType: (count: Int, ufp: Int)] = [:]
        var byComplexity: [ComplexityLevel: Int] = [:]
        for type in TransactionType.allCases { byType[type] = (0, 0) }
        for level in ComplexityLevel.allCases { byComplexity[level] = 0 }

        var ufpTotal = 0
        for tx in transactions {
            ufpTotal += tx.unadjustedFP
            let current = byType[tx.type] ?? (0, 0)
            byType[tx.type] = (current.count + 1, current.ufp + tx.unadjustedFP)
            byComplexity[tx.complexity] = (byComplexity[tx.complexity] ?? 0) + tx.unadjustedFP
        }
        return FPSummary(ufp: ufpTotal, byType: byType, byComplexity: byComplexity)
    }
}
