//
//  AppState.swift
//  FPMeter
//
//  Central observable store. Screens observe this and mutate it
//  through its methods; mutations are persisted to disk.
//

import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var projects: [Project] = []
    @Published private(set) var transactions: [Transaction] = []
    @Published var settings: AppSettings = AppSettings() {
        didSet { persistSettings() }
    }

    private let store: PersistentStoreProtocol

    init(store: PersistentStoreProtocol = PersistentStore.shared) {
        self.store = store
        loadAll()
    }

    // MARK: - Initial load

    private func loadAll() {
        do {
            self.projects = try store.loadProjects()
                .sorted { $0.updatedAt > $1.updatedAt }
            self.transactions = try store.loadTransactions()
            self.settings = try store.loadAppSettings()
        } catch {
            print("AppState load failed: \(error)")
        }
    }

    // MARK: - Projects

    func project(withId id: UUID) -> Project? {
        projects.first { $0.id == id }
    }

    func transactions(forProject projectId: UUID) -> [Transaction] {
        transactions
            .filter { $0.projectId == projectId }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func createProject(_ project: Project) {
        projects.insert(project, at: 0)
        persistProjects()
    }

    func updateProject(_ project: Project) {
        guard let idx = projects.firstIndex(where: { $0.id == project.id }) else { return }
        var updated = project
        updated.updatedAt = Date()
        projects[idx] = updated
        sortProjects()
        persistProjects()
    }

    func deleteProject(_ id: UUID) {
        projects.removeAll { $0.id == id }
        transactions.removeAll { $0.projectId == id }
        persistProjects()
        persistTransactions()
    }

    /// Deep copy of a project with all its transactions.
    func duplicateProject(_ id: UUID) {
        guard let source = project(withId: id) else { return }
        var copy = source
        copy.id = UUID()
        copy.name = source.name + " (copy)"
        copy.createdAt = Date()
        copy.updatedAt = Date()
        projects.insert(copy, at: 0)

        let sourceTxs = transactions(forProject: source.id)
        for tx in sourceTxs {
            var newTx = tx
            newTx.id = UUID()
            newTx.projectId = copy.id
            newTx.createdAt = Date()
            transactions.append(newTx)
        }
        persistProjects()
        persistTransactions()
    }

    // MARK: - Transactions

    func addTransaction(_ tx: Transaction) {
        transactions.append(tx)
        touchProject(tx.projectId)
        persistTransactions()
    }

    func updateTransaction(_ tx: Transaction) {
        guard let idx = transactions.firstIndex(where: { $0.id == tx.id }) else { return }
        transactions[idx] = tx
        touchProject(tx.projectId)
        persistTransactions()
    }

    func deleteTransaction(_ id: UUID) {
        guard let tx = transactions.first(where: { $0.id == id }) else { return }
        transactions.removeAll { $0.id == id }
        touchProject(tx.projectId)
        persistTransactions()
    }

    func duplicateTransaction(_ id: UUID) {
        guard let source = transactions.first(where: { $0.id == id }) else { return }
        var copy = source
        copy.id = UUID()
        copy.name = source.name + " (copy)"
        copy.createdAt = Date()
        transactions.append(copy)
        touchProject(source.projectId)
        persistTransactions()
    }

    // MARK: - Data management

    func clearAllData() {
        projects = []
        transactions = []
        settings = AppSettings()
        try? store.clearAll()
    }

    // MARK: - Aggregates

    /// Total UFP across all transactions of a project.
    func totalUFP(forProject id: UUID) -> Int {
        transactions(forProject: id).reduce(0) { $0 + $1.unadjustedFP }
    }

    /// VAF for the project (derived from its vafInputs).
    func vaf(forProject project: Project) -> Double {
        let vals = GSC.all.map { project.vafInputs[$0.id] ?? 0 }
        return FPCalculatorService.calculateVAF(gscValues: vals)
    }

    /// Total AFP respecting the useVAF setting.
    func totalAFP(forProject project: Project) -> Double {
        let ufp = totalUFP(forProject: project.id)
        let vaf = settings.useVAF ? self.vaf(forProject: project) : 1.0
        return FPCalculatorService.calculateAFP(ufp: ufp, vaf: vaf)
    }

    // MARK: - Private

    private func touchProject(_ id: UUID) {
        guard let idx = projects.firstIndex(where: { $0.id == id }) else { return }
        projects[idx].updatedAt = Date()
        sortProjects()
        persistProjects()
    }

    private func sortProjects() {
        projects.sort { $0.updatedAt > $1.updatedAt }
    }

    private func persistProjects() {
        do { try store.saveProjects(projects) }
        catch { print("Save projects failed: \(error)") }
    }

    private func persistTransactions() {
        do { try store.saveTransactions(transactions) }
        catch { print("Save transactions failed: \(error)") }
    }

    private func persistSettings() {
        do { try store.saveAppSettings(settings) }
        catch { print("Save settings failed: \(error)") }
    }
}
