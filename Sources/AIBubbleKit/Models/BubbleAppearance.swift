import SwiftUI

/// Comprehensive appearance configuration for the AI Bubble
public struct BubbleAppearance {
    
    // MARK: - Bubble Appearance
    public let bubbleSize: CGFloat
    public let bubbleColor: Color
    public let bubbleCornerRadius: CGFloat
    public let bubbleShadowRadius: CGFloat
    public let bubbleShadowColor: Color
    public let bubbleShadowOffset: CGSize
    
    // MARK: - Chat Container
    public let chatBackgroundColor: Color
    public let chatCornerRadius: CGFloat
    public let chatMaxHeight: CGFloat
    public let chatPadding: EdgeInsets
    
    // MARK: - Header
    public let headerBackgroundColor: Color
    public let headerHeight: CGFloat
    public let headerPadding: EdgeInsets
    public let titleFont: Font
    public let titleColor: Color
    public let buttonSize: CGFloat
    public let buttonColor: Color
    public let buttonHoverColor: Color
    
    // MARK: - Messages
    public let messageSpacing: CGFloat
    public let messagePadding: EdgeInsets
    public let userMessageColor: Color
    public let userMessageBackgroundColor: Color
    public let assistantMessageColor: Color
    public let assistantMessageBackgroundColor: Color
    public let messageFont: Font
    public let messageCornerRadius: CGFloat
    
    // MARK: - Input Area
    public let inputBackgroundColor: Color
    public let inputCornerRadius: CGFloat
    public let inputBorderColor: Color
    public let inputBorderWidth: CGFloat
    public let inputFont: Font
    public let inputTextColor: Color
    public let inputPlaceholderColor: Color
    public let sendButtonSize: CGFloat
    public let sendButtonColor: Color
    public let sendButtonDisabledColor: Color
    
    // MARK: - Animations
    public let expandAnimation: Animation
    public let collapseAnimation: Animation
    public let messageAnimation: Animation
    public let buttonAnimation: Animation
    
    // MARK: - Typing Indicator
    public let typingIndicatorColor: Color
    public let typingIndicatorSize: CGFloat
    public let typingIndicatorSpeed: Double
    
    // MARK: - Drag Behavior
    public let dragScaleEffect: CGFloat
    public let snapToEdges: Bool
    public let dragHapticFeedback: Bool
    
    public init(
        // Bubble Appearance
        bubbleSize: CGFloat = 60,
        bubbleColor: Color = .blue,
        bubbleCornerRadius: CGFloat = 30,
        bubbleShadowRadius: CGFloat = 8,
        bubbleShadowColor: Color = .black.opacity(0.2),
        bubbleShadowOffset: CGSize = CGSize(width: 0, height: 4),
        
        // Chat Container
        chatBackgroundColor: Color = .white,
        chatCornerRadius: CGFloat = 16,
        chatMaxHeight: CGFloat = 700,
        chatPadding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        
        // Header
        headerBackgroundColor: Color = Color(.secondarySystemBackground),
        headerHeight: CGFloat = 60,
        headerPadding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16),
        titleFont: Font = .headline,
        titleColor: Color = .primary,
        buttonSize: CGFloat = 16,
        buttonColor: Color = .secondary,
        buttonHoverColor: Color = .primary,
        
        // Messages
        messageSpacing: CGFloat = 12,
        messagePadding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
        userMessageColor: Color = .white,
        userMessageBackgroundColor: Color = .blue,
        assistantMessageColor: Color = .primary,
        assistantMessageBackgroundColor: Color = Color(.systemGray6),
        messageFont: Font = .body,
        messageCornerRadius: CGFloat = 16,
        
        // Input Area
        inputBackgroundColor: Color = Color(.secondarySystemBackground),
        inputCornerRadius: CGFloat = 8,
        inputBorderColor: Color = .clear,
        inputBorderWidth: CGFloat = 0,
        inputFont: Font = .body,
        inputTextColor: Color = .primary,
        inputPlaceholderColor: Color = .secondary,
        sendButtonSize: CGFloat = 24,
        sendButtonColor: Color = .blue,
        sendButtonDisabledColor: Color = .secondary,
        
        // Animations
        expandAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.1),
        collapseAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.8),
        messageAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7),
        buttonAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7),
        
        // Typing Indicator
        typingIndicatorColor: Color = .secondary,
        typingIndicatorSize: CGFloat = 4,
        typingIndicatorSpeed: Double = 0.6,
        
        // Drag Behavior
        dragScaleEffect: CGFloat = 1.1,
        snapToEdges: Bool = true,
        dragHapticFeedback: Bool = true
    ) {
        self.bubbleSize = bubbleSize
        self.bubbleColor = bubbleColor
        self.bubbleCornerRadius = bubbleCornerRadius
        self.bubbleShadowRadius = bubbleShadowRadius
        self.bubbleShadowColor = bubbleShadowColor
        self.bubbleShadowOffset = bubbleShadowOffset
        
        self.chatBackgroundColor = chatBackgroundColor
        self.chatCornerRadius = chatCornerRadius
        self.chatMaxHeight = chatMaxHeight
        self.chatPadding = chatPadding
        
        self.headerBackgroundColor = headerBackgroundColor
        self.headerHeight = headerHeight
        self.headerPadding = headerPadding
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.buttonSize = buttonSize
        self.buttonColor = buttonColor
        self.buttonHoverColor = buttonHoverColor
        
        self.messageSpacing = messageSpacing
        self.messagePadding = messagePadding
        self.userMessageColor = userMessageColor
        self.userMessageBackgroundColor = userMessageBackgroundColor
        self.assistantMessageColor = assistantMessageColor
        self.assistantMessageBackgroundColor = assistantMessageBackgroundColor
        self.messageFont = messageFont
        self.messageCornerRadius = messageCornerRadius
        
        self.inputBackgroundColor = inputBackgroundColor
        self.inputCornerRadius = inputCornerRadius
        self.inputBorderColor = inputBorderColor
        self.inputBorderWidth = inputBorderWidth
        self.inputFont = inputFont
        self.inputTextColor = inputTextColor
        self.inputPlaceholderColor = inputPlaceholderColor
        self.sendButtonSize = sendButtonSize
        self.sendButtonColor = sendButtonColor
        self.sendButtonDisabledColor = sendButtonDisabledColor
        
        self.expandAnimation = expandAnimation
        self.collapseAnimation = collapseAnimation
        self.messageAnimation = messageAnimation
        self.buttonAnimation = buttonAnimation
        
        self.typingIndicatorColor = typingIndicatorColor
        self.typingIndicatorSize = typingIndicatorSize
        self.typingIndicatorSpeed = typingIndicatorSpeed
        
        self.dragScaleEffect = dragScaleEffect
        self.snapToEdges = snapToEdges
        self.dragHapticFeedback = dragHapticFeedback
    }
}

// MARK: - Predefined Themes
public extension BubbleAppearance {
    
    /// Default appearance (current design)
    static let `default` = BubbleAppearance()
    
    /// Dark theme appearance
    static let dark = BubbleAppearance(
        bubbleColor: .purple,
        chatBackgroundColor: Color(.systemBackground),
        headerBackgroundColor: Color(.secondarySystemBackground),
        userMessageBackgroundColor: .purple,
        assistantMessageBackgroundColor: Color(.tertiarySystemBackground),
        inputBackgroundColor: Color(.secondarySystemBackground)
    )
    
    /// Minimal appearance
    static let minimal = BubbleAppearance(
        bubbleColor: .gray,
        bubbleShadowRadius: 0,
        chatCornerRadius: 8,
        headerBackgroundColor: .clear,
        messageCornerRadius: 8,
        inputCornerRadius: 4
    )
    
    /// Colorful appearance
    static let colorful = BubbleAppearance(
        bubbleColor: .orange,
        userMessageBackgroundColor: .orange,
        assistantMessageBackgroundColor: .green.opacity(0.2),
        sendButtonColor: .orange,
        typingIndicatorColor: .orange
    )
    
    /// Corporate appearance
    static let corporate = BubbleAppearance(
        bubbleColor: .indigo,
        titleFont: .title3, userMessageBackgroundColor: .indigo,
        assistantMessageBackgroundColor: .gray.opacity(0.1),
        messageFont: .callout, sendButtonColor: .indigo
    )
}
