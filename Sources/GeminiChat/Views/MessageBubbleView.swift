import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    var body: some View {
        HStack(spacing: 0) {
            if message.role == .user { Spacer(minLength: 80) }

            Text(message.content.isEmpty ? " " : message.content)
                .textSelection(.enabled)
                .font(.system(size: 13.5))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .foregroundStyle(.primary)
                .background {
                    if message.role == .user {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.25),
                                                Color.purple.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(
                                        Color.white.opacity(0.15),
                                        lineWidth: 0.5
                                    )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(
                                        Color.white.opacity(0.12),
                                        lineWidth: 0.5
                                    )
                            )
                    }
                }
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 2)

            if message.role == .model { Spacer(minLength: 80) }
        }
    }
}
