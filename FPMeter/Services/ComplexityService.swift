//
//  ComplexityService.swift
//  FPMeter
//
//  Pure, stateless implementation of the official IFPUG 4.3.1
//  complexity evaluation matrices. Zero UI dependencies — fully unit-testable.
//

import Foundation

enum ComplexityService {

    // MARK: - ILF / EIF Complexity Matrix
    // RET rows: 1, 2–5, 6+
    // DET cols: 1–19, 20–50, 51+
    private static let ilfMatrix: [[ComplexityLevel]] = [
        [.low,     .low,     .average],  // RET = 1
        [.low,     .average, .high],     // RET = 2–5
        [.average, .high,    .high],     // RET = 6+
    ]

    // MARK: - EI Complexity Matrix
    // FTR rows: 0–1, 2, 3+
    // DET cols: 1–4, 5–15, 16+
    private static let eiMatrix: [[ComplexityLevel]] = [
        [.low,     .low,     .average],
        [.low,     .average, .high],
        [.average, .high,    .high],
    ]

    // MARK: - EO / EQ Complexity Matrix
    // FTR rows: 0–1, 2–3, 4+
    // DET cols: 1–5, 6–19, 20+
    private static let eoMatrix: [[ComplexityLevel]] = [
        [.low,     .low,     .average],
        [.low,     .average, .high],
        [.high,    .high,    .high],
    ]

    // MARK: - UFP Weights (IFPUG standard)
    private static let ufpWeights: [TransactionType: [ComplexityLevel: Int]] = [
        .ilf: [.low: 7, .average: 10, .high: 15],
        .eif: [.low: 5, .average: 7,  .high: 10],
        .ei:  [.low: 3, .average: 4,  .high: 6 ],
        .eo:  [.low: 4, .average: 5,  .high: 7 ],
        .eq:  [.low: 3, .average: 4,  .high: 6 ],
    ]

    /// Evaluate a transaction's complexity.
    ///
    /// - Parameters:
    ///   - type:     Transaction type
    ///   - det:      Data Element Types (≥ 1)
    ///   - retOrFtr: RET for ILF/EIF, FTR for EI/EO/EQ
    static func evaluate(type: TransactionType, det: Int, retOrFtr: Int) -> ComplexityResult {
        let level = complexityLevel(type: type, det: det, retOrFtr: retOrFtr)
        let ufp = ufpWeights[type]?[level] ?? 0
        let param = (type == .ilf || type == .eif) ? "RET" : "FTR"
        let rationale = "\(type.rawValue): DET=\(det), \(param)=\(retOrFtr) → \(level.rawValue) (\(ufp) UFP)"
        return ComplexityResult(level: level, unadjustedFP: ufp, rationale: rationale)
    }

    static func ufpWeight(type: TransactionType, level: ComplexityLevel) -> Int {
        ufpWeights[type]?[level] ?? 0
    }

    /// Return the raw 3×3 matrix for a given type (used by the glossary).
    static func matrix(for type: TransactionType) -> [[ComplexityLevel]] {
        switch type {
        case .ilf, .eif: return ilfMatrix
        case .ei:        return eiMatrix
        case .eo, .eq:   return eoMatrix
        }
    }

    // MARK: - Private

    private static func complexityLevel(type: TransactionType, det: Int, retOrFtr: Int) -> ComplexityLevel {
        switch type {
        case .ilf, .eif:
            let row = retOrFtr == 1 ? 0 : (retOrFtr <= 5 ? 1 : 2)
            let col = det <= 19 ? 0 : (det <= 50 ? 1 : 2)
            return ilfMatrix[row][col]
        case .ei:
            let row = retOrFtr <= 1 ? 0 : (retOrFtr == 2 ? 1 : 2)
            let col = det <= 4 ? 0 : (det <= 15 ? 1 : 2)
            return eiMatrix[row][col]
        case .eo, .eq:
            let row = retOrFtr <= 1 ? 0 : (retOrFtr <= 3 ? 1 : 2)
            let col = det <= 5 ? 0 : (det <= 19 ? 1 : 2)
            return eoMatrix[row][col]
        }
    }
}
