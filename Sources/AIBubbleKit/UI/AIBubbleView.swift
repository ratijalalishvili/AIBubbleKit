import SwiftUI

/// Main floating bubble view that contains the AI assistant interface
public struct AIBubbleView: View {
    @ObservedObject var assistant: AIBubbleAssistant
    @State private var inputText: String = ""
    @State private var showClearConfirmation: Bool = false
    @Namespace private var namespace
    
    private let appearance: BubbleAppearance

    // MARK: - Bubble Position and Animation
    @State private var bubblePosition: CGPoint = CGPoint(x: 50, y: 100)
    @State private var isDragging: Bool = false
    
    @GestureState private var dragOffset: CGSize = .zero
    
    
    public init(assistant: AIBubbleAssistant, appearance: BubbleAppearance = .default) {
        self.assistant = assistant
        self.appearance = appearance
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                    // Expanded chat interface
                    if assistant.isActive {
                        expandedChatView(geometry: geometry)
                            .matchedGeometryEffect(id: "bubble", in: namespace)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .bottom))
                            ))
                    }
                
                // Floating bubble
                if !assistant.isActive {
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
        .alert("Clear Chat History", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    assistant.clearChatHistory()
                }
            }
        } message: {
            Text("Are you sure you want to clear all chat history? This action cannot be undone.")
        }
    }
    
    // MARK: - Floating Bubble View
    
    private var floatingBubbleView: some View {
        Button(action: toggleExpanded) {
            ZStack {
                Circle()
                    .fill(bubbleGradient)
                    .frame(width: appearance.bubbleSize, height: appearance.bubbleSize)
                    .shadow(
                        color: appearance.bubbleShadowColor,
                        radius: appearance.bubbleShadowRadius,
                        x: appearance.bubbleShadowOffset.width,
                        y: appearance.bubbleShadowOffset.height
                    )
                
                if assistant.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "message")
                        .font(.system(size: appearance.bubbleSize * 0.4, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .scaleEffect(dragOffset == .zero ? 1.0 : appearance.dragScaleEffect)
        .animation(appearance.buttonAnimation, value: dragOffset)
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
            appearance.chatBackgroundColor
        )
        .cornerRadius(appearance.chatCornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 12)
    }
    
    private var chatHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(assistant.configuration.agentProfile.name)
                    .font(appearance.titleFont)
                    .fontWeight(.semibold)
                    .foregroundColor(appearance.titleColor)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Clear chat button
                Button(action: {
                    showClearConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: appearance.buttonSize, weight: .medium))
                        .foregroundColor(appearance.buttonColor)
                        .scaleEffect(1.0)
                        .animation(appearance.buttonAnimation, value: assistant.conversationHistory.count)
                }
                .disabled(assistant.conversationHistory.isEmpty)
                .opacity(assistant.conversationHistory.isEmpty ? 0.5 : 1.0)
                
                // Close button
                Button(action: { 
                    withAnimation(appearance.collapseAnimation) { 
                        assistant.isActive = false 
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: appearance.buttonSize, weight: .medium))
                        .foregroundColor(appearance.buttonColor)
                        .scaleEffect(assistant.isActive ? 1.0 : 0.8)
                        .animation(appearance.buttonAnimation, value: assistant.isActive)
                }
            }
        }
        .padding(appearance.headerPadding)
        .background(appearance.headerBackgroundColor)
    }
    
    private var chatMessages: some View {
        ZStack {
            appearance.chatBackgroundColor
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: appearance.messageSpacing) {
                        ForEach(assistant.conversationHistory) { message in
                            MessageBubble(message: message, appearance: appearance)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .bottom)),
                                    removal: .scale(scale: 0.9).combined(with: .opacity)
                                ))
                        }
                        
                        if assistant.isProcessing {
                            TypingIndicator(appearance: appearance)
                                .id("typing")
                                .transition(.scale(scale: 0.9).combined(with: .opacity))
                        }
                    }
                    .padding(appearance.messagePadding)
                }
                .frame(maxHeight: appearance.chatMaxHeight)
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
                .font(appearance.inputFont)
                .foregroundColor(appearance.inputTextColor)
                .padding(appearance.messagePadding)
                .background(appearance.inputBackgroundColor)
                .cornerRadius(appearance.inputCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: appearance.inputCornerRadius)
                        .stroke(appearance.inputBorderColor, lineWidth: appearance.inputBorderWidth)
                )
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: appearance.sendButtonSize))
                    .foregroundColor(inputText.isEmpty ? appearance.sendButtonDisabledColor : appearance.sendButtonColor)
                    .scaleEffect(inputText.isEmpty ? 0.9 : 1.0)
                    .animation(appearance.buttonAnimation, value: inputText.isEmpty)
            }
            .disabled(inputText.isEmpty || assistant.isProcessing)
        }
        .padding(appearance.headerPadding)
        .background(appearance.inputBackgroundColor)
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
        withAnimation(appearance.expandAnimation) {
            assistant.toggleActive()
        }
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let message = inputText
        inputText = ""
        
        // Add haptic feedback if enabled
        if appearance.dragHapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        Task {
            await assistant.processTextInput(message)
        }
    }
    
    private func snapToEdges(position: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        guard appearance.snapToEdges else { return position }
        
        let bubbleRadius: CGFloat = appearance.bubbleSize / 2
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
// MARK: - Preview

struct AIBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        let config = AssistantConfiguration.defaultConfiguration(
            appName: "Test App",
            appVersion: "1.0.0",
            userId: "test-user"
        )
        let assistant = AIBubbleAssistant(configuration: config)
        
        VStack {
            AIBubbleView(assistant: assistant, appearance: .default)
                .previewDisplayName("Default")
            
            AIBubbleView(assistant: assistant, appearance: .dark)
                .previewDisplayName("Dark")
            
            AIBubbleView(assistant: assistant, appearance: .colorful)
                .previewDisplayName("Colorful")
        }
    }
}
