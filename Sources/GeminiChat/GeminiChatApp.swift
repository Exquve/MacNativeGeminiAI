import SwiftUI

@main
struct GeminiChatApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Gemini Chat", systemImage: "bubble.left.and.text.bubble.right") {
            MenuBarView()
                .environment(AppState.shared)
        }

        Settings {
            SettingsView()
                .environment(AppState.shared)
        }
    }
}
