import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) var appState
    @State private var keyInput: String = ""
    @State private var saveStatus: String? = nil

    var body: some View {
        @Bindable var state = appState

        Form {
            Section("Google Gemini API Key") {
                SecureField("Enter API key...", text: $keyInput)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Save to Keychain") {
                        if KeychainManager.shared.save(apiKey: keyInput) {
                            appState.apiKey = keyInput
                            saveStatus = "Saved successfully"
                            keyInput = ""
                        } else {
                            saveStatus = "Failed to save"
                        }
                    }
                    .disabled(keyInput.isEmpty)

                    if appState.hasValidKey {
                        Button("Remove Key", role: .destructive) {
                            KeychainManager.shared.delete()
                            appState.apiKey = nil
                            saveStatus = "Key removed"
                        }
                    }
                }

                if let status = saveStatus {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(status.contains("Failed") ? .red : .green)
                }

                if !appState.hasValidKey {
                    Text("Get your API key from Google AI Studio (aistudio.google.com)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Default Model") {
                Picker("Model", selection: $state.selectedModel) {
                    ForEach(GeminiModel.allCases) { model in
                        Text(model.displayName).tag(model)
                    }
                }
            }

            Section("Info") {
                LabeledContent("API Key") {
                    Text(appState.hasValidKey ? "Configured" : "Not Set")
                        .foregroundStyle(appState.hasValidKey ? .green : .red)
                }
                LabeledContent("Hotkey") {
                    Text("\u{2325} Space (Option + Space)")
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 320)
    }
}
