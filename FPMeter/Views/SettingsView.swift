//
//  SettingsView.swift
//  FPMeter
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var config = ProductivityConfig.industryAverage
    @State private var showClearConfirm = false

    private var version: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }

    var body: some View {
        Form {
            Section {
                ForEach(LanguagePreference.allCases) { pref in
                    Button {
                        appState.settings.language = pref
                        HapticsService.selection(enabled: appState.settings.hapticsEnabled)
                    } label: {
                        HStack {
                            Text(languageLabel(pref))
                                .foregroundColor(Theme.text)
                            Spacer()
                            if appState.settings.language == pref {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.primary)
                            }
                        }
                    }
                }
            } header: {
                Text("settings.language")
            }

            Section {
                Button(LocalizedStringKey("settings.presetIndustry")) {
                    config = .industryAverage
                    appState.settings.productivity = config
                }
                Button(LocalizedStringKey("settings.presetExperienced")) {
                    config = .experiencedTeam
                    appState.settings.productivity = config
                }
                Button(LocalizedStringKey("settings.presetComplex")) {
                    config = .complexDomain
                    appState.settings.productivity = config
                }
            } header: {
                Text("settings.presets")
            } footer: {
                Text("settings.productivityDesc")
            }

            Section {
                Stepper(value: $config.low, in: 1...50) {
                    HStack {
                        Text("settings.low"); Spacer()
                        Text("\(config.low)").foregroundColor(Theme.textMuted)
                    }
                }
                Stepper(value: $config.average, in: 1...50) {
                    HStack {
                        Text("settings.average"); Spacer()
                        Text("\(config.average)").foregroundColor(Theme.textMuted)
                    }
                }
                Stepper(value: $config.high, in: 1...50) {
                    HStack {
                        Text("settings.high"); Spacer()
                        Text("\(config.high)").foregroundColor(Theme.textMuted)
                    }
                }
                Button("common.save") {
                    appState.settings.productivity = config
                    HapticsService.success(enabled: appState.settings.hapticsEnabled)
                }
            } header: {
                Text("settings.productivity")
            }

            Section {
                Toggle(LocalizedStringKey("settings.vafToggle"), isOn: $appState.settings.useVAF)
                    .tint(Theme.primary)
                Toggle(LocalizedStringKey("settings.haptics"), isOn: $appState.settings.hapticsEnabled)
                    .tint(Theme.primary)
                Toggle(LocalizedStringKey("settings.quickAdd"), isOn: $appState.settings.quickAddEnabled)
                    .tint(Theme.primary)
            } footer: {
                VStack(alignment: .leading, spacing: 2) {
                    Text("settings.vafToggleDesc")
                    Text("settings.hapticsDesc")
                    Text("settings.quickAddDesc")
                }
            }

            Section {
                Button(role: .destructive) {
                    showClearConfirm = true
                } label: {
                    Label("settings.clearAll", systemImage: "trash")
                }
            } header: {
                Text("settings.data")
            }

            Section {
                HStack {
                    Text("settings.version")
                    Spacer()
                    Text(version).foregroundColor(Theme.textMuted)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("settings.privacy").font(.subheadline.bold())
                    Text("settings.privacyBody").font(.caption).foregroundColor(Theme.textMuted)
                }
                .padding(.vertical, 4)
            } header: {
                Text("settings.about")
            }
        }
        .navigationTitle("settings.title")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { config = appState.settings.productivity }
        .alert(LocalizedStringKey("settings.clearTitle"), isPresented: $showClearConfirm) {
            Button(LocalizedStringKey("settings.clearAll"), role: .destructive) {
                appState.clearAllData()
                HapticsService.warning(enabled: appState.settings.hapticsEnabled)
            }
            Button(LocalizedStringKey("common.cancel"), role: .cancel) { }
        } message: {
            Text("settings.clearBody")
        }
    }

    private func languageLabel(_ pref: LanguagePreference) -> String {
        switch pref {
        case .system: return NSLocalizedString("settings.systemDefault", comment: "")
        case .en: return "English"
        case .ko: return "한국어"
        case .ja: return "日本語"
        }
    }
}
