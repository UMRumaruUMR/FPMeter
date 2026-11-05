//
//  ResultView.swift
//  FPMeter
//

import SwiftUI

struct ResultView: View {
    @EnvironmentObject var appState: AppState
    let projectId: UUID
    @State private var teamSize: Int = 1
    @State private var showCopied = false
    @State private var showShare = false

    private var project: Project? { appState.project(withId: projectId) }
    private var transactions: [Transaction] {
        appState.transactions(forProject: projectId)
    }

    private var summary: FPSummary {
        FPCalculatorService.summarize(transactions)
    }

    private var afp: Double {
        guard let p = project else { return 0 }
        return appState.totalAFP(forProject: p)
    }

    private var vafValue: Double {
        guard let p = project else { return 1.0 }
        return appState.settings.useVAF ? appState.vaf(forProject: p) : 1.0
    }

    private var mm: MMEstimate {
        MMEstimatorService.estimate(afp: afp, config: appState.settings.productivity)
    }

    var body: some View {
        if transactions.isEmpty {
            emptyView
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    sectionHeader("result.breakdown")

                    HStack(spacing: 8) {
                        metricCard(label: "UFP", value: "\(summary.ufp)")
                        metricCard(label: "VAF", value: String(format: "%.2f", vafValue))
                        metricCard(label: "AFP", value: String(format: "%.1f", afp), highlight: true)
                    }

                    breakdownTable
                    sectionHeader("result.estimate")
                    mmSection
                    sectionHeader("result.export")
                    exportButtons
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("result.title")
            .navigationBarTitleDisplayMode(.inline)
            .alert("result.copied", isPresented: $showCopied) {
                Button("common.ok") { }
            }
            .sheet(isPresented: $showShare) {
                ShareSheet(items: [summaryText])
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 44))
                .foregroundColor(Theme.textLight)
            Text("project.emptyTx").font(.headline)
            Text("project.emptyTxBody")
                .font(.caption).foregroundColor(Theme.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bg)
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.caption).fontWeight(.bold)
            .foregroundColor(Theme.textMuted)
            .textCase(.uppercase)
    }

    private func metricCard(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2).fontWeight(.semibold)
                .foregroundColor(Theme.textMuted)
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

    private var breakdownTable: some View {
        VStack(spacing: 0) {
            HStack {
                Text("result.typeCol").frame(maxWidth: .infinity, alignment: .leading)
                Text("result.countCol").frame(width: 50, alignment: .trailing)
                Text("result.ufpCol").frame(width: 50, alignment: .trailing)
                Text("result.percentCol").frame(width: 50, alignment: .trailing)
            }
            .font(.caption.bold())
            .foregroundColor(Theme.textMuted)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Theme.surfaceAlt)

            ForEach(TransactionType.displayOrder, id: \.self) { type in
                let data = summary.byType[type] ?? (count: 0, ufp: 0)
                if data.count > 0 {
                    Divider()
                    HStack {
                        HStack(spacing: 6) {
                            Text(type.rawValue)
                                .font(.caption.bold())
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Theme.typeColor(type))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                            Text(LocalizedStringKey("type.\(type.rawValue).short"))
                                .font(.caption)
                                .foregroundColor(Theme.text)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(data.count)").frame(width: 50, alignment: .trailing)
                        Text("\(data.ufp)").frame(width: 50, alignment: .trailing).bold()
                        Text(summary.ufp > 0 ? "\(Int(round(Double(data.ufp) / Double(summary.ufp) * 100)))%" : "0%")
                            .frame(width: 50, alignment: .trailing)
                    }
                    .font(.caption)
                    .foregroundColor(Theme.text)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                }
            }

            Divider()
            HStack {
                Text("Σ").frame(maxWidth: .infinity, alignment: .leading).bold()
                Text("\(transactions.count)").frame(width: 50, alignment: .trailing).bold()
                Text("\(summary.ufp)").frame(width: 50, alignment: .trailing).bold()
                Text("100%").frame(width: 50, alignment: .trailing).bold()
            }
            .font(.caption).foregroundColor(Theme.text)
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background(Theme.surfaceAlt)
        }
        .background(Theme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
    }

    private var mmSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // three-point range bar
            HStack {
                mmCell(labelKey: "result.low", value: mm.low, color: Theme.success)
                mmCell(labelKey: "result.average", value: mm.average, color: Theme.accent)
                mmCell(labelKey: "result.high", value: mm.high, color: Theme.warning)
            }
            HStack(spacing: 0) {
                Rectangle().fill(Theme.success)
                Rectangle().fill(Theme.accent)
                Rectangle().fill(Theme.warning)
            }
            .frame(height: 6)
            .cornerRadius(3)

            // team size
            HStack {
                Text("result.teamSize").font(.subheadline)
                Spacer()
                Stepper("\(teamSize)", value: $teamSize, in: 1...20)
                    .labelsHidden()
                Text("\(teamSize)").frame(minWidth: 24)
            }
            .padding(.top, 8)

            // calendar
            HStack {
                calendarCell(labelKey: "result.low", value: MMEstimatorService.toCalendarMonths(mm: mm.low, teamSize: teamSize))
                calendarCell(labelKey: "result.average", value: MMEstimatorService.toCalendarMonths(mm: mm.average, teamSize: teamSize))
                calendarCell(labelKey: "result.high", value: MMEstimatorService.toCalendarMonths(mm: mm.high, teamSize: teamSize))
            }
            .padding(10)
            .background(Theme.surfaceAlt)
            .cornerRadius(8)

            Text(String(format: NSLocalizedString("result.productivityNote", comment: ""),
                        "\(appState.settings.productivity.low) / \(appState.settings.productivity.average) / \(appState.settings.productivity.high)"))
                .font(.caption)
                .foregroundColor(Theme.accent)

            Text("result.industryNote")
                .font(.caption2)
                .foregroundColor(Theme.textMuted)
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
    }

    private func mmCell(labelKey: LocalizedStringKey, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(labelKey).font(.caption2).foregroundColor(Theme.textMuted).textCase(.uppercase)
            Text(String(format: "%.1f", value)).font(.title3.bold()).foregroundColor(color)
            Text("M/M").font(.caption2).foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func calendarCell(labelKey: LocalizedStringKey, value: Double) -> some View {
        VStack(spacing: 2) {
            Text(labelKey).font(.caption2).foregroundColor(Theme.textMuted)
            Text(String(format: "%.1f", value)).font(.headline).foregroundColor(Theme.text)
            Text("result.calendarMonths").font(.caption2).foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    private var exportButtons: some View {
        HStack(spacing: 8) {
            Button {
                UIPasteboard.general.string = summaryText
                HapticsService.success(enabled: appState.settings.hapticsEnabled)
                showCopied = true
            } label: {
                Label("result.copySummary", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.primary))
                    .foregroundColor(Theme.primary)
            }
            Button {
                showShare = true
            } label: {
                Label("result.share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    private var summaryText: String {
        guard let p = project else { return "" }
        var out: [String] = []
        out.append("📊 FP Meter — \(p.name)")
        out.append("━━━━━━━━━━━━━━━━━━━━━")
        out.append("\(NSLocalizedString("project.totalUFP", comment: "")): \(summary.ufp)")
        out.append("\(NSLocalizedString("project.vaf", comment: "")): \(String(format: "%.2f", vafValue))")
        out.append("\(NSLocalizedString("project.totalAFP", comment: "")): \(String(format: "%.1f", afp))")
        out.append("")
        out.append("\(NSLocalizedString("result.summary", comment: "")):")
        for type in TransactionType.displayOrder {
            let d = summary.byType[type] ?? (count: 0, ufp: 0)
            if d.count > 0 {
                out.append("  \(type.rawValue): \(d.count) · \(d.ufp) UFP")
            }
        }
        out.append("")
        out.append("\(NSLocalizedString("result.estimate", comment: "")):")
        out.append("  \(NSLocalizedString("result.low", comment: "")): \(String(format: "%.1f", mm.low)) PM")
        out.append("  \(NSLocalizedString("result.average", comment: "")): \(String(format: "%.1f", mm.average)) PM")
        out.append("  \(NSLocalizedString("result.high", comment: "")): \(String(format: "%.1f", mm.high)) PM")
        return out.joined(separator: "\n")
    }
}

// iOS share sheet bridge
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
