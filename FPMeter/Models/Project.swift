//
//  Project.swift
//  FPMeter
//

import Foundation

/// One of the 14 IFPUG General System Characteristics.
/// Each is rated 0 (no influence) through 5 (strong influence throughout).
struct GSCDefinition: Identifiable {
    let id: String       // key used in VAFInput dictionary
    let labelKey: String // Localizable.strings key
    let descriptionKey: String

    var name: String { NSLocalizedString(labelKey, comment: "") }
    var desc: String { NSLocalizedString(descriptionKey, comment: "") }
}

enum GSC {
    /// 14 GSCs in IFPUG standard order.
    static let all: [GSCDefinition] = [
        .init(id: "dataCommunications", labelKey: "gsc.dataCommunications", descriptionKey: "gsc.dataCommunications.desc"),
        .init(id: "distributedDataProcessing", labelKey: "gsc.distributedDataProcessing", descriptionKey: "gsc.distributedDataProcessing.desc"),
        .init(id: "performance", labelKey: "gsc.performance", descriptionKey: "gsc.performance.desc"),
        .init(id: "heavilyUsedConfiguration", labelKey: "gsc.heavilyUsedConfiguration", descriptionKey: "gsc.heavilyUsedConfiguration.desc"),
        .init(id: "transactionRate", labelKey: "gsc.transactionRate", descriptionKey: "gsc.transactionRate.desc"),
        .init(id: "onlineDataEntry", labelKey: "gsc.onlineDataEntry", descriptionKey: "gsc.onlineDataEntry.desc"),
        .init(id: "endUserEfficiency", labelKey: "gsc.endUserEfficiency", descriptionKey: "gsc.endUserEfficiency.desc"),
        .init(id: "onlineUpdate", labelKey: "gsc.onlineUpdate", descriptionKey: "gsc.onlineUpdate.desc"),
        .init(id: "complexProcessing", labelKey: "gsc.complexProcessing", descriptionKey: "gsc.complexProcessing.desc"),
        .init(id: "reusability", labelKey: "gsc.reusability", descriptionKey: "gsc.reusability.desc"),
        .init(id: "installationEase", labelKey: "gsc.installationEase", descriptionKey: "gsc.installationEase.desc"),
        .init(id: "operationalEase", labelKey: "gsc.operationalEase", descriptionKey: "gsc.operationalEase.desc"),
        .init(id: "multipleSites", labelKey: "gsc.multipleSites", descriptionKey: "gsc.multipleSites.desc"),
        .init(id: "facilitateChange", labelKey: "gsc.facilitateChange", descriptionKey: "gsc.facilitateChange.desc"),
    ]

    /// Empty VAF inputs — every GSC = 0 (no influence).
    static var emptyVAFInputs: [String: Int] {
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, 0) })
    }
}

struct Project: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var projectDescription: String?
    var language: String?
    /// Ratings 0..5 per GSC id.
    var vafInputs: [String: Int]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        projectDescription: String? = nil,
        language: String? = nil,
        vafInputs: [String: Int]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.projectDescription = projectDescription
        self.language = language
        self.vafInputs = vafInputs ?? GSC.emptyVAFInputs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
