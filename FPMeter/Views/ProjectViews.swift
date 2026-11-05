//
//  ProjectViews.swift
//  FPMeter
//

import SwiftUI

// MARK: - New Project

struct NewProjectView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var language = ""
    @State private var showError = false

    var body: some View {
        Form {
            Section {
                TextField("project.namePlaceholder", text: $name)
            } header: {
                Text("project.name")
            }

            Section {
                TextField("project.descriptionPlaceholder", text: $description, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                Text("project.description")
            }

            Section {
                TextField("project.languagePlaceholder", text: $language)
            } header: {
                Text("project.language")
            }
        }
        .navigationTitle("dashboard.newProject")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("common.save") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .alert("common.error", isPresented: $showError) {
            Button("common.ok") { }
        } message: {
            Text("transaction.errorProjectNameRequired")
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { showError = true; return }
        let project = Project(
            name: trimmed,
            projectDescription: description.trimmingCharacters(in: .whitespaces).isEmpty ? nil : description,
            language: language.trimmingCharacters(in: .whitespaces).isEmpty ? nil : language
        )
        appState.createProject(project)
        HapticsService.success(enabled: appState.settings.hapticsEnabled)
        dismiss()
    }
}

// MARK: - Project Detail

struct ProjectDetailView: View {
    @EnvironmentObject var appState: AppState
    let projectId: UUID

    @State private var selectedTab = 0
    @State private var showNewTransaction = false
    @State private var editingTransaction: Transaction?
    @State private var showQuickAdd = false
    @State private var showResult = false

    private var project: Project? { appState.project(withId: projectId) }
    private var transactions: [Transaction] { appState.transactions(forProject: projectId) }

    var body: some View {
        if let project = project {
            VStack(spacing: 0) {
                header(project: project)
                Picker("", selection: $selectedTab) {
                    Text("project.tabs.transactions").tag(0)
                    Text("project.tabs.vaf").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)

                if selectedTab == 0 {
                    TransactionsTab(
                        projectId: projectId,
                        onEdit: { editingTransaction = $0 },
                        onNew: { showNewTransaction = true },
                        onQuickAdd: appState.settings.quickAddEnabled ? { showQuickAdd = true } : nil
                    )
                } else {
                    VAFTab(project: project)
                }

                Button {
                    showResult = true
                } label: {
                    HStack {
                        Text("project.calculateResult")
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(transactions.isEmpty)
                .opacity(transactions.isEmpty ? 0.4 : 1)
                .padding()
                .background(Theme.surface)
            }
            .background(Theme.bg)
            .navigationTitle(project.name)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showNewTransaction) {
                NavigationStack {
                    TransactionFormView(projectId: projectId, editing: nil)
                }
            }
            .sheet(item: $editingTransaction) { tx in
                NavigationStack {
                    TransactionFormView(projectId: projectId, editing: tx)
                }
            }
            .sheet(isPresented: $showQuickAdd) {
                QuickAddSheet(projectId: projectId)
                    .presentationDetents([.medium, .large])
            }
            .navigationDestination(isPresented: $showResult) {
                ResultView(projectId: projectId)
            }
        }
    }

    private func header(project: Project) -> some View {
        HStack(spacing: 8) {
            summaryCard(label: "project.totalUFP", value: "\(appState.totalUFP(forProject: projectId))")
            summaryCard(label: "project.vaf", value: String(format: "%.2f", appState.vaf(forProject: project)))
            summaryCard(label: "project.totalAFP", value: String(format: "%.1f", appState.totalAFP(forProject: project)), highlight: true)
        }
        .padding()
    }

    private func summaryCard(label: LocalizedStringKey, value: String, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2).fontWeight(.semibold)
                .foregroundColor(Theme.textMuted)
                .textCase(.uppercase)
            Text(value)
                .font(.title2).fontWeight(.bold)
                .foregroundColor(highlight ? Theme.primary : Theme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.surface)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.border))
    }
}

// MARK: - Transactions tab

private struct TransactionsTab: View {
    @EnvironmentObject var appState: AppState
    let projectId: UUID
    let onEdit: (Transaction) -> Void
    let onNew: () -> Void
    let onQuickAdd: (() -> Void)?

    private var transactions: [Transaction] { appState.transactions(forProject: projectId) }

    var body: some View {
        if transactions.isEmpty {
            VStack(spacing: 14) {
                Image(systemName: "doc.text")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.textLight)
                Text("project.emptyTx").font(.headline).foregroundColor(Theme.text)
                Text("project.emptyTxBody").font(.caption)
                    .foregroundColor(Theme.textMuted).multilineTextAlignment(.center)
                Button {
                    onNew()
                } label: {
                    Label("project.addTransaction", systemImage: "plus")
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background(Theme.primary).foregroundColor(.white)
                        .cornerRadius(10)
                }
                if let onQuickAdd = onQuickAdd {
                    Button {
                        onQuickAdd()
                    } label: {
                        Label("quickAdd.title", systemImage: "square.grid.2x2")
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primary))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            List {
                ForEach(TransactionType.displayOrder, id: \.self) { type in
                    let items = transactions.filter { $0.type == type }
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { tx in
                                TransactionRow(transaction: tx)
                                    .contentShape(Rectangle())
                                    .onTapGesture { onEdit(tx) }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            appState.deleteTransaction(tx.id)
                                            HapticsService.warning(enabled: appState.settings.hapticsEnabled)
                                        } label: {
                                            Label("common.delete", systemImage: "trash")
                                        }
                                        Button {
                                            appState.duplicateTransaction(tx.id)
                                            HapticsService.success(enabled: appState.settings.hapticsEnabled)
                                        } label: {
                                            Label("common.duplicate", systemImage: "doc.on.doc")
                                        }
                                        .tint(Theme.accent)
                                    }
                            }
                        } header: {
                            HStack {
                                Circle().fill(Theme.typeColor(type)).frame(width: 8, height: 8)
                                Text(LocalizedStringKey("type.\(type.rawValue).short"))
                                Spacer()
                                Text("\(items.count)")
                            }
                            .font(.caption).foregroundColor(Theme.textMuted)
                        }
                    }
                }

                Section {
                    Button {
                        onNew()
                    } label: {
                        Label("project.addTransaction", systemImage: "plus")
                    }
                    if let onQuickAdd = onQuickAdd {
                        Button {
                            onQuickAdd()
                        } label: {
                            Label("quickAdd.title", systemImage: "square.grid.2x2")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Rectangle()
                .fill(Theme.typeColor(transaction.type))
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.name)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(Theme.text)
                        .lineLimit(1)
                    Spacer()
                    Text("\(transaction.unadjustedFP) UFP")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(Theme.primary)
                }
                HStack {
                    Text("DET=\(transaction.det) · \(transaction.type.secondaryParamName)=\(transaction.type == .ilf || transaction.type == .eif ? transaction.ret : transaction.ftr)")
                        .font(.caption).foregroundColor(Theme.textMuted)
                    Spacer()
                    ComplexityPill(level: transaction.complexity, size: .small)
                }
            }
            .padding(.leading, 6)
        }
    }
}

// MARK: - VAF Tab

private struct VAFTab: View {
    @EnvironmentObject var appState: AppState
    let project: Project
    @State private var inputs: [String: Int] = [:]
    @State private var showSaved = false

    var body: some View {
        let sum = inputs.values.reduce(0, +)
        let vaf = FPCalculatorService.calculateVAF(gscValues: GSC.all.map { inputs[$0.id] ?? 0 })

        return ScrollView {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("TDI").font(.caption2).foregroundColor(Theme.textMuted)
                        Text("\(sum) / 70").font(.title2.bold()).foregroundColor(Theme.primary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("VAF").font(.caption2).foregroundColor(Theme.textMuted)
                        Text(String(format: "%.2f", vaf)).font(.title2.bold()).foregroundColor(Theme.primary)
                    }
                }
                .padding()
                .background(Theme.surface)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))

                Text("project.vafDescription")
                    .font(.caption).foregroundColor(Theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(Array(GSC.all.enumerated()), id: \.element.id) { idx, gsc in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text("\(idx + 1)")
                                .font(.headline).foregroundColor(Theme.accent)
                                .frame(width: 20, alignment: .leading)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(gsc.name).font(.subheadline.bold())
                                Text(gsc.desc).font(.caption).foregroundColor(Theme.textMuted)
                            }
                        }
                        HStack(spacing: 4) {
                            ForEach(0...5, id: \.self) { v in
                                Button {
                                    inputs[gsc.id] = v
                                    HapticsService.selection(enabled: appState.settings.hapticsEnabled)
                                } label: {
                                    Text("\(v)")
                                        .font(.subheadline.bold())
                                        .frame(maxWidth: .infinity, minHeight: 36)
                                        .background((inputs[gsc.id] ?? 0) == v ? Theme.primary : Theme.surface)
                                        .foregroundColor((inputs[gsc.id] ?? 0) == v ? .white : Theme.textMuted)
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
                }

                Button {
                    var updated = project
                    updated.vafInputs = inputs
                    appState.updateProject(updated)
                    HapticsService.success(enabled: appState.settings.hapticsEnabled)
                    showSaved = true
                } label: {
                    Text("project.saveVAF")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .alert("project.vafSaved", isPresented: $showSaved) {
            Button("common.ok") { }
        }
        .onAppear {
            var m = GSC.emptyVAFInputs
            for (k, v) in project.vafInputs { m[k] = v }
            inputs = m
        }
    }
}

// MARK: - Complexity pill shared component

struct ComplexityPill: View {
    enum Size { case small, medium }
    let level: ComplexityLevel
    var size: Size = .medium

    var body: some View {
        let color = Theme.complexityColor(level)
        return Text(level.rawValue)
            .font(size == .small ? .caption2 : .caption)
            .fontWeight(.semibold)
            .padding(.horizontal, size == .small ? 6 : 10)
            .padding(.vertical, size == .small ? 2 : 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
