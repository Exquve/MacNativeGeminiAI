import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            // Floating bubbles grow upward
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(appState.messages.enumerated()), id: \.element.id) { index, message in
                        MessageBubbleView(
                            message: message,
                            isLatest: index == appState.messages.count - 1
                        )
                        .transition(
                            .asymmetric(
                                insertion: .scale(scale: 0.3, anchor: message.role == .user ? .bottomTrailing : .bottomLeading)
                                    .combined(with: .opacity)
                                    .combined(with: .offset(y: 30)),
                                removal: .scale(scale: 0.5).combined(with: .opacity)
                            )
                        )
                    }

                    // Typing indicator when streaming and model message is still empty
                    if appState.isStreaming,
                       let last = appState.messages.last,
                       last.role == .model && last.content.isEmpty {
                        TypingIndicatorView()
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .animation(.spring(duration: 0.45, bounce: 0.3), value: appState.messages.count)
            }
            .defaultScrollAnchor(.bottom)
            .scrollIndicators(.never)

            // Pill-shaped input bar at the bottom
            InputFieldView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
    }
}

// MARK: - Typing Indicator (3 bouncing dots)
struct TypingIndicatorView: View {
    @State private var dotOffsets: [Bool] = [false, false, false]

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 7, height: 7)
                        .offset(y: dotOffsets[index] ? -6 : 0)
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
        .onAppear {
            for i in 0..<3 {
                withAnimation(
                    .easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.15)
                ) {
                    dotOffsets[i] = true
                }
            }
        }
    }
}
