import AppKit

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        PanelController.shared.setup(appState: AppState.shared)
        HotKeyManager.shared.register()

        NotificationCenter.default.addObserver(
            forName: HotKeyManager.toggleNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                PanelController.shared.toggle()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyManager.shared.unregister()
    }
}
