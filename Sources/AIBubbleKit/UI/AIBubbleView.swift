import SwiftUI

/// Main floating bubble view that contains the AI assistant interface
public struct AIBubbleView: View {
    @ObservedObject var assistant: AIBubbleAssistant
    @State private var isExpanded: Bool = false
    @State private var inputText: String = ""
    @Namespace private var namespace

    // MARK: - Bubble Position and Animation
    @State private var bubblePosition: CGPoint = CGPoint(x: 50, y: 100)
    @State private var isDragging: Bool = false
    
    @GestureState private var dragOffset: CGSize = .zero
    
    
    public init(assistant: AIBubbleAssistant) {
        self.assistant = assistant
        
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Expanded chat interface
                if isExpanded {
                    expandedChatView(geometry: geometry)
                        .matchedGeometryEffect(id: "bubble", in: namespace)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
                
                // Floating bubble
                if !isExpanded {
                    floatingBubbleView
                        .matchedGeometryEffect(id: "bubble", in: namespace, isSource: true)
                        .position(bubblePosition)
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation
                                }
                                .onEnded { value in
                                    // Commit the final position and snap to edges
                                    withAnimation(.spring()) {
                                        let newPoint = CGPoint(
                                            x: bubblePosition.x + value.translation.width,
                                            y: bubblePosition.y + value.translation.height
                                        )
                                        bubblePosition = snapToEdges(position: newPoint, in: geometry)
                                    }
                                }
                        )
                }
            }
        }
        .onAppear {
            // Initialize bubble position
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                bubblePosition = CGPoint(
                    x: window.bounds.width - 60,
                    y: window.bounds.height * 0.3
                )
            }
        }
    }
    
    // MARK: - Floating Bubble View
    
    private var floatingBubbleView: some View {
        Button(action: toggleExpanded) {
            ZStack {
                Circle()
                    .fill(bubbleGradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                if assistant.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "message")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .scaleEffect(dragOffset == .zero ? 1.0 : 1.1)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: dragOffset)
    }
    
    // MARK: - Expanded Chat View
    
    private func expandedChatView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Header
            chatHeader
            
            // Messages
            chatMessages
            
            // Input area
            chatInput
        }
        .background(
            Color(.systemBackground)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 12)
    }
    
    private var chatHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(assistant.configuration.agentProfile.name)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Close button
                Button(action: { withAnimation { isExpanded = false } }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }
    
    private var chatMessages: some View {
        ZStack {
            Color.white
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(assistant.conversationHistory) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if assistant.isProcessing {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: 700)
                .onChange(of: assistant.conversationHistory.count) { _ in
                    if let lastMessage = assistant.conversationHistory.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: assistant.isProcessing) { isProcessing in
                    if isProcessing {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
    
    private var chatInput: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(inputText.isEmpty ? .secondary : .blue)
            }
            .disabled(inputText.isEmpty || assistant.isProcessing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Helper Views
    
    private var bubbleGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .purple] ,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Actions
    
    private func toggleExpanded() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isExpanded.toggle()
        }
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = inputText
        inputText = ""
        
        Task {
            await assistant.processTextInput(message)
        }
    }
    
    private func snapToEdges(position: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        let bubbleRadius: CGFloat = 30
        let safeAreaInsets = geometry.safeAreaInsets
        
        var x = position.x
        var y = position.y
        
        // Snap to left or right edge
        if x < geometry.size.width / 2 {
            x = bubbleRadius + safeAreaInsets.leading + 10
        } else {
            x = geometry.size.width - bubbleRadius - safeAreaInsets.trailing - 10
        }
        
        // Keep within vertical bounds
        y = max(bubbleRadius + safeAreaInsets.top + 10, 
                min(y, geometry.size.height - bubbleRadius - safeAreaInsets.bottom - 10))
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Message Bubble View

// MARK: - Typing Indicator

// MARK: - Preview

struct AIBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        let config = AssistantConfiguration.defaultConfiguration(
            appName: "Test App",
            appVersion: "1.0.0",
            userId: "test-user"
        )
        let assistant = AIBubbleAssistant(configuration: config)
        
        AIBubbleView(assistant: assistant)
            .previewDisplayName("AIBubble View")
    }
}
