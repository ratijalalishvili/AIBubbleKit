import SwiftUI

struct MessageBubble: View {
    let message: ConversationMessage
    let appearance: BubbleAppearance
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(appearance.messageFont)
                    .padding(appearance.messagePadding)
                    .background(messageBubbleBackground)
                    .foregroundColor(messageBubbleTextColor)
                    .cornerRadius(appearance.messageCornerRadius)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.role == .assistant {
                Spacer(minLength: 50)
            }
        }
    }
    
    private var messageBubbleBackground: Color {
        message.role == .user ? appearance.userMessageBackgroundColor : appearance.assistantMessageBackgroundColor
    }
    
    private var messageBubbleTextColor: Color {
        message.role == .user ? appearance.userMessageColor : appearance.assistantMessageColor
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
