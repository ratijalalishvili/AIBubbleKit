import SwiftUI

struct TypingIndicator: View {
    let appearance: BubbleAppearance
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(appearance.typingIndicatorColor)
                        .frame(width: appearance.typingIndicatorSize, height: appearance.typingIndicatorSize)
                        .offset(y: animationOffset)
                        .animation(
                            .easeInOut(duration: appearance.typingIndicatorSpeed)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: animationOffset
                        )
                }
            }
            .padding(appearance.messagePadding)
            .background(appearance.assistantMessageBackgroundColor)
            .cornerRadius(appearance.messageCornerRadius)
            
            Spacer(minLength: 50)
        }
        .onAppear {
            animationOffset = -4
        }
    }
}
