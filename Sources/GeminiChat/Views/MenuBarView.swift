import SwiftUI

struct MenuBarView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        @Bindable var state = appState

        Button("Toggle Chat  (\u{2325}Space)") {
            PanelController.shared.toggle()
        }
        .keyboardShortcut(.space, modifiers: .option)

        Divider()

        Button("New Conversation") {
            appState.newConversation()
        }

        Divider()

        Picker("Model", selection: $state.selectedModel) {
            ForEach(GeminiModel.allCases) { model in
                Text(model.displayName).tag(model)
            }
        }

        Divider()

        SettingsLink {
            Text("Settings...")
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
