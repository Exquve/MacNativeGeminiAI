import AppKit
import SwiftUI

@MainActor
final class PanelController {
    static let shared = PanelController()

    private var panel: ChatPanel?
    private var clickMonitor: Any?

    private init() {}

    func setup(appState: AppState) {
        let chatView = ChatView()
            .environment(appState)
        panel = ChatPanel(contentView: chatView)
    }

    func toggle() {
        guard let panel else { return }
        if panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        guard let panel else { return }
        positionAtBottomCenter()
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        AppState.shared.isPanelVisible = true
        startMonitoringClicks()
    }

    func hide() {
        guard let panel, panel.isVisible else { return }
        AppState.shared.isPanelVisible = false
        stopMonitoringClicks()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak panel] in
            panel?.orderOut(nil)
            panel?.alphaValue = 1
        })
    }

    // Global monitor: only fires for clicks OUTSIDE our app's windows.
    // Clicks inside the panel (TextField, buttons) never trigger this.
    private func startMonitoringClicks() {
        stopMonitoringClicks()
        clickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            Task { @MainActor in
                self?.hide()
            }
        }
    }

    private func stopMonitoringClicks() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
    }

    private func positionAtBottomCenter() {
        guard let panel, let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let panelWidth: CGFloat = 600
        let panelHeight: CGFloat = 500
        let bottomPadding: CGFloat = 80

        let x = screenFrame.origin.x + (screenFrame.width - panelWidth) / 2
        let y = screenFrame.origin.y + bottomPadding

        panel.setFrame(
            NSRect(x: x, y: y, width: panelWidth, height: panelHeight),
            display: true
        )
    }
}
