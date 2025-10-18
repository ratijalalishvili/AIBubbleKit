# Contributing to AIBubbleKit

Thank you for your interest in contributing to AIBubbleKit! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0+ deployment target
- Swift 5.7 or later
- Git

### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/AIBubbleKit.git
   cd AIBubbleKit
   ```
3. **Open the project** in Xcode:
   ```bash
   open Package.swift
   ```
4. **Build the framework** to ensure everything works:
   - Select the `AIBubbleKit` scheme
   - Build (⌘+B)

## Project Structure

```
AIBubbleKit/
├── Sources/
│   └── AIBubbleKit/
│       ├── AIBubbleKit.swift          # Main framework API
│       ├── AIBubbleAssistant.swift    # Core assistant logic
│       ├── AIBubbleView.swift         # SwiftUI bubble interface
│       ├── Models.swift               # Data models and configuration
│       ├── FunctionHandler.swift      # Function calling system
│       └── SpeechManager.swift        # Voice processing
├── Tests/
│   └── AIBubbleKitTests/
├── Examples/
│   └── AIBubbleExample/              # Example iOS app
├── Package.swift                     # Swift Package Manager configuration
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

## Contribution Guidelines

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Maintain consistent indentation (4 spaces)
- Use `@available` annotations for iOS version requirements

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add voice activity detection
fix: Resolve bubble positioning on iPad
docs: Update README with new features
refactor: Simplify function handler registration
```

### Pull Request Process

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the guidelines above

3. **Add tests** for new functionality (if applicable)

4. **Update documentation** as needed

5. **Test your changes**:
   - Build the framework
   - Run the example app
   - Test on different iOS versions

6. **Submit a pull request** with:
   - Clear description of changes
   - Reference to any related issues
   - Screenshots for UI changes
   - Testing notes

### Testing

#### Unit Tests

Add unit tests for new functionality in `Tests/AIBubbleKitTests/`:

```swift
import XCTest
@testable import AIBubbleKit

class AIBubbleAssistantTests: XCTestCase {
    func testAssistantInitialization() {
        let config = AssistantConfiguration.defaultConfiguration(
            appName: "Test App",
            appVersion: "1.0.0",
            userId: "test-user"
        )
        let assistant = AIBubbleAssistant(configuration: config)
        XCTAssertNotNil(assistant)
    }
}
```

#### Integration Testing

Test your changes with the example app:

1. Open `Examples/AIBubbleExample/AIBubbleExample.xcodeproj`
2. Update the framework reference if needed
3. Build and run on device/simulator
4. Test all functionality manually

## Areas for Contribution

### High Priority

- **AI Model Integration** - Connect to actual AI models (OpenAI, Anthropic, etc.)
- **Enhanced Voice Features** - Better speech recognition and TTS
- **Custom UI Themes** - More appearance customization options
- **Performance Optimization** - Improve response times and memory usage
- **Accessibility** - VoiceOver and accessibility improvements

### Medium Priority

- **Additional Function Types** - More built-in functions
- **Conversation Persistence** - Save chat history
- **Multi-language Support** - Internationalization
- **Analytics Integration** - Usage tracking and insights
- **Error Handling** - Better error recovery and user feedback

### Low Priority

- **Widget Support** - iOS widget integration
- **macOS Support** - Cross-platform compatibility
- **WatchOS Support** - Apple Watch integration
- **Custom Animations** - More bubble animations
- **Plugin System** - Third-party function plugins

## Bug Reports

When reporting bugs, please include:

1. **iOS version** and device model
2. **Steps to reproduce** the issue
3. **Expected behavior** vs actual behavior
4. **Screenshots** or screen recordings
5. **Console logs** (if applicable)
6. **Sample code** that reproduces the issue

## Feature Requests

For feature requests, please:

1. **Check existing issues** to avoid duplicates
2. **Describe the use case** and motivation
3. **Provide mockups** or examples if applicable
4. **Consider implementation complexity** and maintainability

## Code Review Process

All contributions require code review:

1. **Automated checks** must pass (build, tests, linting)
2. **At least one reviewer** must approve
3. **Address feedback** promptly and constructively
4. **Maintain clean commit history** with squashing if needed

## Release Process

Releases are managed by maintainers:

1. **Version bumping** follows semantic versioning
2. **Release notes** document all changes
3. **Tagged releases** on GitHub
4. **Swift Package Manager** updates automatically

## Community Guidelines

### Be Respectful

- Use welcoming and inclusive language
- Respect different viewpoints and experiences
- Accept constructive criticism gracefully
- Focus on what's best for the community

### Be Collaborative

- Help others learn and contribute
- Share knowledge and best practices
- Provide constructive feedback
- Work together toward common goals

### Be Professional

- Stay on topic in discussions
- Keep issues and PRs focused
- Use appropriate channels for different types of communication
- Respect maintainers' time and decisions

## Getting Help

- **GitHub Discussions** - General questions and ideas
- **GitHub Issues** - Bug reports and feature requests
- **Email** - Private or sensitive matters: maintainers@example.com
- **Documentation** - Check README and inline documentation first

## Recognition

Contributors are recognized in:

- **CONTRIBUTORS.md** - List of all contributors
- **Release notes** - Major contributors highlighted
- **GitHub contributors** - Automatic recognition on GitHub

## License

By contributing to AIBubbleKit, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to AIBubbleKit! Your efforts help make AI assistants more accessible and beautiful in iOS apps. 🫧✨
