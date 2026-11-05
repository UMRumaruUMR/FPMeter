//
//  QuickAddService.swift
//  FPMeter
//

import Foundation

enum QuickAddBundleId: String, CaseIterable, Identifiable {
    case crud
    case auth
    case report

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .crud:   return "quickAdd.crudTitle"
        case .auth:   return "quickAdd.loginTitle"
        case .report: return "quickAdd.reportTitle"
        }
    }

    var descriptionKey: String {
        switch self {
        case .crud:   return "quickAdd.crudDesc"
        case .auth:   return "quickAdd.loginDesc"
        case .report: return "quickAdd.reportDesc"
        }
    }
}

private struct BundleTransaction {
    let name: String
    let type: TransactionType
    let det: Int
    let retOrFtr: Int
}

enum QuickAddService {

    private static let bundles: [QuickAddBundleId: [BundleTransaction]] = [
        .crud: [
            BundleTransaction(name: "Entity",         type: .ilf, det: 10, retOrFtr: 1),
            BundleTransaction(name: "Create Entity",  type: .ei,  det: 8,  retOrFtr: 1),
            BundleTransaction(name: "Update Entity",  type: .ei,  det: 8,  retOrFtr: 1),
            BundleTransaction(name: "Delete Entity",  type: .ei,  det: 2,  retOrFtr: 1),
            BundleTransaction(name: "List Entities",  type: .eq,  det: 6,  retOrFtr: 1),
        ],
        .auth: [
            BundleTransaction(name: "Users",          type: .ilf, det: 10, retOrFtr: 1),
            BundleTransaction(name: "Login",          type: .ei,  det: 3,  retOrFtr: 1),
            BundleTransaction(name: "Logout",         type: .ei,  det: 1,  retOrFtr: 1),
            BundleTransaction(name: "Password Reset", type: .ei,  det: 3,  retOrFtr: 1),
        ],
        .report: [
            BundleTransaction(name: "Generate Report",    type: .eo, det: 20, retOrFtr: 3),
            BundleTransaction(name: "Filter by Date",     type: .eq, det: 4,  retOrFtr: 1),
            BundleTransaction(name: "Filter by Category", type: .eq, det: 4,  retOrFtr: 1),
        ],
    ]

    /// Build concrete Transactions for a bundle, ready to be inserted.
    static func transactions(forBundle id: QuickAddBundleId, projectId: UUID) -> [Transaction] {
        guard let items = bundles[id] else { return [] }
        return items.map { item in
            let isData = (item.type == .ilf || item.type == .eif)
            let result = ComplexityService.evaluate(type: item.type, det: item.det, retOrFtr: item.retOrFtr)
            return Transaction(
                projectId: projectId,
                name: item.name,
                type: item.type,
                det: item.det,
                ret: isData ? item.retOrFtr : 0,
                ftr: isData ? 0 : item.retOrFtr,
                complexity: result.level,
                unadjustedFP: result.unadjustedFP
            )
        }
    }
}
