import SwiftUI

struct InputFieldView: View {
    @Environment(AppState.self) var appState
    @FocusState private var isFocused: Bool
    @State private var glowRotation: Double = 0
    @State private var barScale: CGFloat = 0.85
    @State private var barOpacity: Double = 0.0

    var body: some View {
        @Bindable var state = appState

        HStack(spacing: 10) {
            // Sparkle icon with pulse during streaming
            Image(systemName: "sparkle")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse, isActive: appState.isStreaming)

            // Text input
            TextField("Ask anything...", text: $state.currentInput, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .focused($isFocused)
                .onSubmit { send() }
                .disabled(appState.isStreaming)
                .font(.system(size: 15))

            // Send / Stop button
            if appState.isStreaming {
                ProgressView()
                    .controlSize(.small)
                    .transition(.opacity)
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
                }
                .buttonStyle(.plain)
                .transition(.scale(scale: 0.5).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: appState.isStreaming)
        .animation(.spring(duration: 0.3), value: appState.currentInput.isEmpty)
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
                    .blur(radius: 6)
                    .opacity(isFocused ? 0.6 : 0.3)

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
        // Entrance animation
        .scaleEffect(barScale)
        .opacity(barOpacity)
        .onAppear {
            isFocused = true
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                glowRotation = 360
            }
            withAnimation(.spring(duration: 0.5, bounce: 0.25)) {
                barScale = 1.0
                barOpacity = 1.0
            }
        }
        .onChange(of: appState.isPanelVisible) { _, visible in
            if visible {
                barScale = 0.85
                barOpacity = 0.0
                withAnimation(.spring(duration: 0.5, bounce: 0.25)) {
                    barScale = 1.0
                    barOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
        }
    }

    private func send() {
        // Micro-bounce feedback
        withAnimation(.spring(duration: 0.12)) {
            barScale = 0.97
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.spring(duration: 0.2, bounce: 0.4)) {
                barScale = 1.0
            }
        }
        Task { await appState.sendMessage() }
    }
}
