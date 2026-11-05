//
//  DashboardView.swift
//  FPMeter
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @State private var showNewProject = false
    @State private var projectToDelete: Project?

    var body: some View {
        NavigationStack {
            Group {
                if appState.projects.isEmpty {
                    emptyState
                } else {
                    projectList
                }
            }
            .background(Theme.bg)
            .navigationTitle("dashboard.title")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        NavigationLink {
                            GlossaryView()
                        } label: {
                            Image(systemName: "book")
                        }
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                fab
            }
            .sheet(isPresented: $showNewProject) {
                NavigationStack {
                    NewProjectView()
                }
            }
            .alert(
                LocalizedStringKey("project.deleteProjectTitle"),
                isPresented: Binding(
                    get: { projectToDelete != nil },
                    set: { if !$0 { projectToDelete = nil } }
                ),
                presenting: projectToDelete
            ) { project in
                Button(LocalizedStringKey("common.delete"), role: .destructive) {
                    appState.deleteProject(project.id)
                    HapticsService.warning(enabled: appState.settings.hapticsEnabled)
                    projectToDelete = nil
                }
                Button(LocalizedStringKey("common.cancel"), role: .cancel) {
                    projectToDelete = nil
                }
            } message: { _ in
                Text("project.deleteProjectBody")
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Theme.surface)
                    .frame(width: 96, height: 96)
                    .overlay(Circle().stroke(Theme.border))
                Image(systemName: "function")
                    .font(.system(size: 44))
                    .foregroundColor(Theme.accent)
            }
            Text("dashboard.emptyTitle")
                .font(.title3).fontWeight(.bold)
                .foregroundColor(Theme.text)
            Text("dashboard.emptyBody")
                .font(.body)
                .foregroundColor(Theme.textMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                showNewProject = true
            } label: {
                Label("dashboard.createFirst", systemImage: "plus")
                    .frame(maxWidth: 280)
                    .padding()
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding()
    }

    // MARK: - Project list

    private var projectList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appState.projects) { project in
                    NavigationLink {
                        ProjectDetailView(projectId: project.id)
                    } label: {
                        ProjectCard(project: project)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            appState.duplicateProject(project.id)
                            HapticsService.success(enabled: appState.settings.hapticsEnabled)
                        } label: {
                            Label("common.duplicate", systemImage: "doc.on.doc")
                        }
                        Button(role: .destructive) {
                            projectToDelete = project
                        } label: {
                            Label("common.delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
    }

    // MARK: - FAB

    private var fab: some View {
        Button {
            showNewProject = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Theme.primary)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
        }
        .padding(20)
    }
}

// MARK: - ProjectCard

private struct ProjectCard: View {
    @EnvironmentObject var appState: AppState
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(project.name)
                    .font(.headline)
                    .foregroundColor(Theme.text)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Theme.textLight)
                    .font(.caption)
            }
            if let desc = project.projectDescription, !desc.isEmpty {
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
                    .lineLimit(2)
            }
            HStack {
                statView(label: "AFP", value: String(format: "%.1f", appState.totalAFP(forProject: project)), highlight: true)
                Divider().frame(height: 28)
                statView(label: "UFP", value: "\(appState.totalUFP(forProject: project.id))")
                Divider().frame(height: 28)
                statView(label: "VAF", value: String(format: "%.2f", appState.vaf(forProject: project)))
            }
            .padding(10)
            .background(Theme.surfaceAlt)
            .cornerRadius(8)

            Text("dashboard.updatedAt \(formatted(project.updatedAt))")
                .font(.caption2)
                .foregroundColor(Theme.textLight)
        }
        .padding()
        .background(Theme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
        .shadow(color: .black.opacity(0.03), radius: 3, y: 1)
    }

    private func statView(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2).fontWeight(.semibold)
                .foregroundColor(Theme.textMuted)
            Text(value)
                .font(.headline)
                .foregroundColor(highlight ? Theme.primary : Theme.text)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatted(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }
}
