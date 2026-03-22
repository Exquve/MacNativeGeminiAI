import Carbon

final class HotKeyManager {
    static let shared = HotKeyManager()
    static let toggleNotification = Notification.Name("com.geminichat.hotkey.toggle")

    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    private init() {}

    func register() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let callback: EventHandlerUPP = { _, event, _ -> OSStatus in
            NotificationCenter.default.post(
                name: HotKeyManager.toggleNotification,
                object: nil
            )
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            nil,
            &handlerRef
        )

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = 0x474D4E49 // 'GMNI'
        hotKeyID.id = 1

        RegisterEventHotKey(
            UInt32(kVK_Space),
            UInt32(optionKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }
}
