//
//  TransactionFormView.swift
//  FPMeter
//

import SwiftUI

struct TransactionFormView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let projectId: UUID
    let editing: Transaction?

    @State private var name = ""
    @State private var type: TransactionType = .ei
    @State private var det = 1
    @State private var ret = 1
    @State private var ftr = 1
    @State private var notes = ""
    @State private var showError = false
    @State private var errorMessage: LocalizedStringKey = ""

    @State private var lastLevel: ComplexityLevel = .low
    @State private var badgeScale: CGFloat = 1.0

    private var isDataFunction: Bool { type == .ilf || type == .eif }
    private var secondaryValue: Int { isDataFunction ? ret : ftr }

    private var preview: ComplexityResult {
        guard det >= 1 else {
            return ComplexityResult(level: .low, unadjustedFP: 0, rationale: NSLocalizedString("transaction.errorDetMin", comment: ""))
        }
        return ComplexityService.evaluate(type: type, det: det, retOrFtr: secondaryValue)
    }

    var body: some View {
        Form {
            Section { TextField("transaction.namePlaceholder", text: $name) }
                header: { Text("transaction.name") }

            Section {
                Picker("", selection: $type) {
                    ForEach(TransactionType.allCases) { t in
                        VStack(alignment: .leading) {
                            Text(LocalizedStringKey("type.\(t.rawValue).short"))
                                .font(.subheadline.bold())
                            Text(LocalizedStringKey("type.\(t.rawValue).desc"))
                                .font(.caption).foregroundColor(.secondary)
                        }.tag(t)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: { Text("transaction.selectType") }

            Section {
                Stepper("DET: \(det)", value: $det, in: 1...999)
                Text("transaction.detHint").font(.caption).foregroundColor(.secondary)
            } header: { Text("transaction.det") }

            Section {
                if isDataFunction {
                    Stepper("RET: \(ret)", value: $ret, in: 1...999)
                    Text("transaction.retHint").font(.caption).foregroundColor(.secondary)
                } else {
                    Stepper("FTR: \(ftr)", value: $ftr, in: 0...999)
                    Text("transaction.ftrHint").font(.caption).foregroundColor(.secondary)
                }
            } header: { Text(isDataFunction ? "transaction.ret" : "transaction.ftr") }

            Section {
                TextField("transaction.notesPlaceholder", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                Text("transaction.notes")
            }

            // Live preview
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("transaction.livePreview")
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(Theme.textMuted)
                        .textCase(.uppercase)
                    HStack(alignment: .center, spacing: 16) {
                        ComplexityPill(level: preview.level)
                            .scaleEffect(badgeScale)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: badgeScale)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(preview.unadjustedFP)").font(.title.bold())
                                .foregroundColor(Theme.primary)
                            Text("UFP").font(.caption).foregroundColor(Theme.textMuted)
                        }
                    }
                    Text(preview.rationale)
                        .font(.caption).foregroundColor(Theme.textMuted)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(editing == nil ? "project.newTransaction" : "common.edit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("common.cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(editing == nil ? LocalizedStringKey("transaction.save") : LocalizedStringKey("transaction.update")) {
                    save()
                }
            }
        }
        .alert("common.error", isPresented: $showError) {
            Button("common.ok") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear { loadEditing() }
        .onChange(of: preview.level) { newLevel in
            guard det >= 1 else { return }
            HapticsService.complexityChanged(newLevel, enabled: appState.settings.hapticsEnabled)
            badgeScale = 0.85
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                badgeScale = 1.0
            }
            lastLevel = newLevel
        }
    }

    private func loadEditing() {
        guard let tx = editing else { return }
        name = tx.name
        type = tx.type
        det = tx.det
        ret = tx.ret > 0 ? tx.ret : 1
        ftr = tx.ftr
        notes = tx.notes ?? ""
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "transaction.errorNameRequired"
            showError = true
            return
        }
        guard det >= 1 else {
            errorMessage = "transaction.errorDetMin"
            showError = true
            return
        }
        let result = ComplexityService.evaluate(type: type, det: det, retOrFtr: secondaryValue)
        let tx = Transaction(
            id: editing?.id ?? UUID(),
            projectId: projectId,
            name: trimmed,
            type: type,
            det: det,
            ret: isDataFunction ? ret : 0,
            ftr: isDataFunction ? 0 : ftr,
            complexity: result.level,
            unadjustedFP: result.unadjustedFP,
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes,
            createdAt: editing?.createdAt ?? Date()
        )
        if editing == nil {
            appState.addTransaction(tx)
        } else {
            appState.updateTransaction(tx)
        }
        HapticsService.success(enabled: appState.settings.hapticsEnabled)
        dismiss()
    }
}

// MARK: - Quick Add sheet

struct QuickAddSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    let projectId: UUID

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("quickAdd.description")
                        .font(.subheadline)
                        .foregroundColor(Theme.textMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ForEach(QuickAddBundleId.allCases) { bundle in
                        Button {
                            addBundle(bundle)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizedStringKey(bundle.titleKey))
                                        .font(.headline).foregroundColor(Theme.text)
                                    Text(LocalizedStringKey(bundle.descriptionKey))
                                        .font(.caption).foregroundColor(Theme.textMuted)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2).foregroundColor(Theme.primary)
                            }
                            .padding()
                            .background(Theme.surfaceAlt)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("quickAdd.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.close") { dismiss() }
                }
            }
        }
    }

    private func addBundle(_ id: QuickAddBundleId) {
        let txs = QuickAddService.transactions(forBundle: id, projectId: projectId)
        for tx in txs { appState.addTransaction(tx) }
        HapticsService.success(enabled: appState.settings.hapticsEnabled)
        dismiss()
    }
}
