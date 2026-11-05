//
//  PersistentStore.swift
//  FPMeter
//
//  A tiny file-backed JSON store. For an app of this scale,
//  FileManager + Codable is plenty fast and keeps zero native
//  dependencies — no SQLite.swift, no Core Data complexity.
//

import Foundation

protocol PersistentStoreProtocol {
    func loadProjects() throws -> [Project]
    func saveProjects(_ projects: [Project]) throws
    func loadTransactions() throws -> [Transaction]
    func saveTransactions(_ transactions: [Transaction]) throws
    func loadAppSettings() throws -> AppSettings
    func saveAppSettings(_ settings: AppSettings) throws
    func clearAll() throws
}

final class PersistentStore: PersistentStoreProtocol {
    static let shared = PersistentStore()

    private let fileManager: FileManager
    private let baseURL: URL

    private let projectsURL: URL
    private let transactionsURL: URL
    private let settingsURL: URL

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.baseURL = docs.appendingPathComponent("FPMeter", isDirectory: true)
        self.projectsURL = baseURL.appendingPathComponent("projects.json")
        self.transactionsURL = baseURL.appendingPathComponent("transactions.json")
        self.settingsURL = baseURL.appendingPathComponent("settings.json")
        try? fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
    }

    // MARK: - Projects

    func loadProjects() throws -> [Project] {
        try loadArray(at: projectsURL)
    }

    func saveProjects(_ projects: [Project]) throws {
        try saveArray(projects, to: projectsURL)
    }

    // MARK: - Transactions

    func loadTransactions() throws -> [Transaction] {
        try loadArray(at: transactionsURL)
    }

    func saveTransactions(_ transactions: [Transaction]) throws {
        try saveArray(transactions, to: transactionsURL)
    }

    // MARK: - Settings

    func loadAppSettings() throws -> AppSettings {
        guard fileManager.fileExists(atPath: settingsURL.path) else {
            return AppSettings()
        }
        let data = try Data(contentsOf: settingsURL)
        return try decoder.decode(AppSettings.self, from: data)
    }

    func saveAppSettings(_ settings: AppSettings) throws {
        let data = try encoder.encode(settings)
        try data.write(to: settingsURL, options: .atomic)
    }

    // MARK: - Maintenance

    func clearAll() throws {
        for url in [projectsURL, transactionsURL, settingsURL] {
            if fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
        }
    }

    // MARK: - Helpers

    private func loadArray<T: Decodable>(at url: URL) throws -> [T] {
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        return try decoder.decode([T].self, from: data)
    }

    private func saveArray<T: Encodable>(_ items: [T], to url: URL) throws {
        let data = try encoder.encode(items)
        try data.write(to: url, options: .atomic)
    }
}
