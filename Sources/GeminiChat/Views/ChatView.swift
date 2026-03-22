import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) var appState

    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)

            // Floating bubbles grow upward
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(appState.messages) { message in
                        MessageBubbleView(message: message)
                    }
                }
                .padding(.horizontal, 20)
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
