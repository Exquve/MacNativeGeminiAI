import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage
    let isLatest: Bool

    @State private var appeared = false
    @State private var shimmerOffset: CGFloat = -200

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
                                // Shimmer effect on model bubbles while streaming
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .clear,
                                                Color.white.opacity(0.06),
                                                .clear
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .offset(x: shimmerOffset)
                                    .mask(RoundedRectangle(cornerRadius: 18))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(
                                        Color.white.opacity(0.12),
                                        lineWidth: 0.5
                                    )
                            )
                    }
                }
                .shadow(color: .black.opacity(0.2), radius: appeared ? 8 : 2, x: 0, y: appeared ? 2 : 0)
                // Droplet-like entrance animation
                .scaleEffect(appeared ? 1.0 : 0.3, anchor: message.role == .user ? .bottomTrailing : .bottomLeading)
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 20)
                .blur(radius: appeared ? 0 : 3)

            if message.role == .model { Spacer(minLength: 80) }
        }
        .onAppear {
            if !appeared {
                withAnimation(.spring(duration: 0.5, bounce: 0.35)) {
                    appeared = true
                }
                // Shimmer for model responses
                if message.role == .model {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                        shimmerOffset = 400
                    }
                }
            }
        }
    }
}
