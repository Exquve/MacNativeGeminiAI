import AppKit
import SwiftUI

class ChatPanel: NSPanel {
    init(contentView rootView: some View) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .floating
        isMovableByWindowBackground = false
        isReleasedWhenClosed = false
        animationBehavior = .utilityWindow
        hasShadow = false
        backgroundColor = .clear
        isOpaque = false

        collectionBehavior.insert(.fullScreenAuxiliary)
        collectionBehavior.insert(.canJoinAllSpaces)

        let hostingView = NSHostingView(
            rootView: rootView
                .ignoresSafeArea()
        )
        hostingView.layer?.backgroundColor = .clear
        self.contentView = hostingView
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func cancelOperation(_ sender: Any?) {
        PanelController.shared.hide()
    }

    override func resignKey() {
        super.resignKey()
        PanelController.shared.hide()
    }
}
