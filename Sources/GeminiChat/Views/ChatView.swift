import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            // Floating bubbles grow upward
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(appState.messages) { message in
                        MessageBubbleView(message: message)
                    }

                    // Typing indicator while waiting for first token
                    if appState.isStreaming,
                       let last = appState.messages.last,
                       last.role == .model && last.content.isEmpty {
                        TypingIndicatorView()
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .defaultScrollAnchor(.bottom)
            .scrollIndicators(.never)

            // Pill-shaped input bar at the bottom
            InputFieldView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Nearly invisible background so the window captures
        // mouse/scroll events even in transparent areas
        .background(Color.black.opacity(0.001))
    }
}

// MARK: - Typing Indicator (3 bouncing dots)

struct TypingIndicatorView: View {
    @State private var active = false

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 7, height: 7)
                        .offset(y: active ? -5 : 0)
                        .animation(
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: active
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)

            Spacer(minLength: 80)
        }
        .onAppear { active = true }
    }
}
