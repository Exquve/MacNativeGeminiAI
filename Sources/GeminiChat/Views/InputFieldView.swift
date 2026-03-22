import SwiftUI

struct InputFieldView: View {
    @Environment(AppState.self) var appState
    @FocusState private var isFocused: Bool
    @State private var glowRotation: Double = 0
    @State private var sparkleScale: CGFloat = 1.0
    @State private var sendButtonScale: CGFloat = 1.0
    @State private var inputBarScale: CGFloat = 0.8
    @State private var inputBarOpacity: Double = 0.0

    var body: some View {
        @Bindable var state = appState

        HStack(spacing: 10) {
            // Sparkle icon with breathing animation
            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(sparkleScale)
                .symbolEffect(.pulse, isActive: appState.isStreaming)

            // Text input
            TextField("Ask anything...", text: $state.currentInput, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .focused($isFocused)
                .onSubmit { send() }
                .disabled(appState.isStreaming)
                .font(.system(size: 15))

            // Send / Stop button with animation
            if appState.isStreaming {
                ProgressView()
                    .controlSize(.small)
                    .transition(.scale.combined(with: .opacity))
            } else if !appState.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button(action: send) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(sendButtonScale)
                }
                .buttonStyle(.plain)
                .transition(.scale(scale: 0.5).combined(with: .opacity))
                .onHover { hovering in
                    withAnimation(.spring(duration: 0.25, bounce: 0.5)) {
                        sendButtonScale = hovering ? 1.15 : 1.0
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background {
            ZStack {
                // Glow border effect (animated rotating gradient)
                Capsule()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .blue, .purple, .pink, .orange, .yellow, .green, .blue
                            ]),
                            center: .center,
                            angle: .degrees(glowRotation)
                        )
                    )
                    .blur(radius: isFocused ? 8 : 4)
                    .opacity(isFocused ? 0.7 : 0.3)

                // Inner pill background
                Capsule()
                    .fill(.ultraThinMaterial)

                // Inner border
                Capsule()
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
            }
        }
        .shadow(color: .blue.opacity(0.15), radius: 20, x: 0, y: 0)
        .padding(.horizontal, 40)
        .padding(.bottom, 4)
        .scaleEffect(inputBarScale)
        .opacity(inputBarOpacity)
        .animation(.spring(duration: 0.3), value: appState.currentInput.isEmpty)
        .onAppear {
            isFocused = true
            // Rotating glow
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                glowRotation = 360
            }
            // Sparkle breathing
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                sparkleScale = 1.15
            }
            // Entrance animation for the input bar itself
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                inputBarScale = 1.0
                inputBarOpacity = 1.0
            }
        }
        .onChange(of: appState.isPanelVisible) { _, visible in
            if visible {
                inputBarScale = 0.8
                inputBarOpacity = 0.0
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                    inputBarScale = 1.0
                    inputBarOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
        }
    }

    private func send() {
        // Micro bounce on send
        withAnimation(.spring(duration: 0.15, bounce: 0.5)) {
            inputBarScale = 0.97
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(duration: 0.2, bounce: 0.4)) {
                inputBarScale = 1.0
            }
        }
        Task { await appState.sendMessage() }
    }
}
