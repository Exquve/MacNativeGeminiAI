import SwiftUI

@Observable
@MainActor
final class AppState {
    static let shared = AppState()

    var messages: [ChatMessage] = []
    var currentInput: String = ""
    var isStreaming: Bool = false
    var isPanelVisible: Bool = false

    var selectedModel: GeminiModel = .flash25
    var apiKey: String? = nil
    var hasValidKey: Bool { apiKey != nil && !(apiKey!.isEmpty) }

    var conversationTurns: [GeminiRequest.Content] = []

    private init() {
        self.apiKey = KeychainManager.shared.retrieve()
    }

    func sendMessage() async {
        let text = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming, hasValidKey else { return }

        currentInput = ""
        isStreaming = true

        messages.append(ChatMessage(role: .user, content: text))

        conversationTurns.append(
            GeminiRequest.Content(role: "user", parts: [.init(text: text)])
        )

        let placeholderID = UUID()
        messages.append(ChatMessage(id: placeholderID, role: .model, content: ""))

        do {
            let stream = GeminiService.shared.streamGenerate(
                model: selectedModel,
                contents: conversationTurns,
                apiKey: apiKey!
            )
            for try await chunk in stream {
                if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                    messages[idx].content += chunk
                }
            }

            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                conversationTurns.append(
                    GeminiRequest.Content(
                        role: "model",
                        parts: [.init(text: messages[idx].content)]
                    )
                )
            }
        } catch {
            if let idx = messages.firstIndex(where: { $0.id == placeholderID }) {
                messages[idx].content = "Error: \(error.localizedDescription)"
            }
        }

        isStreaming = false
    }

    func newConversation() {
        messages.removeAll()
        conversationTurns.removeAll()
        currentInput = ""
        isStreaming = false
    }
}
