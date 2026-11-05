//
//  Transaction.swift
//  FPMeter
//

import Foundation

enum TransactionType: String, CaseIterable, Codable, Identifiable {
    case ilf = "ILF"
    case eif = "EIF"
    case ei  = "EI"
    case eo  = "EO"
    case eq  = "EQ"

    var id: String { rawValue }

    /// Data functions use RET; transactional functions use FTR.
    var secondaryParamName: String {
        switch self {
        case .ilf, .eif: return "RET"
        case .ei, .eo, .eq: return "FTR"
        }
    }

    /// Ordering used across the app (grouping, charts).
    static let displayOrder: [TransactionType] = [.ilf, .eif, .ei, .eo, .eq]
}

enum ComplexityLevel: String, CaseIterable, Codable {
    case low = "Low"
    case average = "Average"
    case high = "High"
}

struct Transaction: Identifiable, Codable, Equatable {
    var id: UUID
    var projectId: UUID
    var name: String
    var type: TransactionType
    var det: Int              // Data Element Types
    var ret: Int              // Record Element Types (for ILF/EIF)
    var ftr: Int              // File Types Referenced (for EI/EO/EQ)
    var complexity: ComplexityLevel
    var unadjustedFP: Int
    var notes: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        projectId: UUID,
        name: String,
        type: TransactionType,
        det: Int,
        ret: Int = 0,
        ftr: Int = 0,
        complexity: ComplexityLevel,
        unadjustedFP: Int,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.projectId = projectId
        self.name = name
        self.type = type
        self.det = det
        self.ret = ret
        self.ftr = ftr
        self.complexity = complexity
        self.unadjustedFP = unadjustedFP
        self.notes = notes
        self.createdAt = createdAt
    }
}
