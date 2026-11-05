//
//  GlossaryView.swift
//  FPMeter
//

import SwiftUI

struct GlossaryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("glossary.intro")
                    .font(.subheadline)
                    .foregroundColor(Theme.textMuted)

                sectionHeader("glossary.quickReference")

                matrixCard(title: "ILF / EIF",
                           rowHeader: "RET ↓", colHeader: "DET →",
                           rows: ["1", "2–5", "6+"],
                           cols: ["1–19", "20–50", "51+"],
                           matrix: ComplexityService.matrix(for: .ilf),
                           accent: Theme.typeColor(.ilf))

                matrixCard(title: "EI",
                           rowHeader: "FTR ↓", colHeader: "DET →",
                           rows: ["0–1", "2", "3+"],
                           cols: ["1–4", "5–15", "16+"],
                           matrix: ComplexityService.matrix(for: .ei),
                           accent: Theme.typeColor(.ei))

                matrixCard(title: "EO / EQ",
                           rowHeader: "FTR ↓", colHeader: "DET →",
                           rows: ["0–1", "2–3", "4+"],
                           cols: ["1–5", "6–19", "20+"],
                           matrix: ComplexityService.matrix(for: .eo),
                           accent: Theme.typeColor(.eo))

                sectionHeader("glossary.title")

                ForEach(terms, id: \.id) { term in
                    TermCard(term: term)
                }
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationTitle("glossary.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.caption).fontWeight(.bold)
            .foregroundColor(Theme.textMuted)
            .textCase(.uppercase)
            .padding(.top, 8)
    }

    private func matrixCard(title: String,
                            rowHeader: String, colHeader: String,
                            rows: [String], cols: [String],
                            matrix: [[ComplexityLevel]],
                            accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.subheadline.bold()).foregroundColor(Theme.text)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text(colHeader).font(.caption2).foregroundColor(Theme.textMuted)
                        Spacer()
                        Text(rowHeader).font(.caption2).foregroundColor(Theme.textMuted)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(6)
                    .background(Theme.surfaceAlt)
                    ForEach(cols, id: \.self) { col in
                        Divider().frame(width: 0.5)
                        Text(col).font(.caption.bold()).foregroundColor(Theme.textMuted)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .background(Theme.surfaceAlt)
                    }
                }
                ForEach(Array(matrix.enumerated()), id: \.offset) { rIdx, row in
                    Divider().frame(height: 0.5)
                    HStack(spacing: 0) {
                        Text(rows[rIdx]).font(.caption.bold()).foregroundColor(Theme.textMuted)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(Theme.surfaceAlt)
                        ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                            Divider().frame(width: 0.5)
                            let c = Theme.complexityColor(cell)
                            Text(String(cell.rawValue.prefix(1)))
                                .font(.subheadline.bold())
                                .foregroundColor(c)
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(c.opacity(0.15))
                        }
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))
            .cornerRadius(8)

            HStack(spacing: 12) {
                ForEach(ComplexityLevel.allCases, id: \.self) { level in
                    HStack(spacing: 4) {
                        Circle().fill(Theme.complexityColor(level)).frame(width: 8, height: 8)
                        Text(level.rawValue).font(.caption2).foregroundColor(Theme.textMuted)
                    }
                }
            }
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.border)
        )
        .overlay(
            Rectangle().fill(accent).frame(width: 4).cornerRadius(2, corners: [.topLeft, .bottomLeft]),
            alignment: .leading
        )
    }

    // MARK: - Term definitions

    private struct TermDef: Identifiable {
        let id: String
        let abbreviation: String
        let accent: Color
        let hasWhenToUse: Bool
        let parameters: String?
    }

    private var terms: [TermDef] {
        [
            .init(id: "ILF", abbreviation: "ILF", accent: Theme.typeColor(.ilf), hasWhenToUse: true, parameters: "DET + RET"),
            .init(id: "EIF", abbreviation: "EIF", accent: Theme.typeColor(.eif), hasWhenToUse: true, parameters: "DET + RET"),
            .init(id: "EI",  abbreviation: "EI",  accent: Theme.typeColor(.ei),  hasWhenToUse: true, parameters: "DET + FTR"),
            .init(id: "EO",  abbreviation: "EO",  accent: Theme.typeColor(.eo),  hasWhenToUse: true, parameters: "DET + FTR"),
            .init(id: "EQ",  abbreviation: "EQ",  accent: Theme.typeColor(.eq),  hasWhenToUse: true, parameters: "DET + FTR"),
            .init(id: "DET", abbreviation: "DET", accent: Theme.accent, hasWhenToUse: false, parameters: nil),
            .init(id: "RET", abbreviation: "RET", accent: Theme.accent, hasWhenToUse: false, parameters: nil),
            .init(id: "FTR", abbreviation: "FTR", accent: Theme.accent, hasWhenToUse: false, parameters: nil),
            .init(id: "UFP", abbreviation: "UFP", accent: Theme.primary, hasWhenToUse: false, parameters: nil),
            .init(id: "AFP", abbreviation: "AFP", accent: Theme.primary, hasWhenToUse: false, parameters: nil),
            .init(id: "VAF", abbreviation: "VAF", accent: Theme.primary, hasWhenToUse: false, parameters: nil),
            .init(id: "GSC", abbreviation: "GSC", accent: Theme.textMuted, hasWhenToUse: false, parameters: nil),
            .init(id: "MM",  abbreviation: "M/M", accent: Theme.warning, hasWhenToUse: false, parameters: nil),
        ]
    }

    private struct TermCard: View {
        let term: TermDef
        @State private var expanded = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation { expanded.toggle() }
                } label: {
                    HStack {
                        Text(term.abbreviation)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(term.accent)
                            .cornerRadius(4)
                        Text(titleForTerm(term.id))
                            .font(.subheadline.bold()).foregroundColor(Theme.text)
                        Spacer()
                        Image(systemName: expanded ? "chevron.up" : "chevron.down")
                            .font(.caption).foregroundColor(Theme.textMuted)
                    }
                    .padding()
                }
                .buttonStyle(.plain)

                if expanded {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(LocalizedStringKey("glossary.terms.\(term.id).desc"))
                            .font(.subheadline).foregroundColor(Theme.text)

                        infoBox(labelKey: "glossary.example",
                                text: NSLocalizedString("glossary.terms.\(term.id).example", comment: ""))

                        if let params = term.parameters {
                            infoBox(labelKey: "glossary.parameters", text: params)
                        }

                        if term.hasWhenToUse {
                            infoBox(labelKey: "glossary.whenToUse",
                                    text: NSLocalizedString("glossary.terms.\(term.id).whenToUse", comment: ""))
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
            }
            .background(Theme.surface)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
            .overlay(
                Rectangle().fill(term.accent).frame(width: 4),
                alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        private func infoBox(labelKey: LocalizedStringKey, text: String) -> some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(labelKey)
                    .font(.caption2).fontWeight(.bold)
                    .foregroundColor(Theme.textMuted)
                    .textCase(.uppercase)
                Text(text)
                    .font(.caption)
                    .foregroundColor(Theme.text)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surfaceAlt)
                    .cornerRadius(6)
            }
        }

        private func titleForTerm(_ id: String) -> String {
            if ["ILF", "EIF", "EI", "EO", "EQ"].contains(id) {
                return NSLocalizedString("type.\(id).short", comment: "")
            }
            return id
        }
    }
}

// MARK: - Rounded corner helper (for matrix card accent bar)

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
