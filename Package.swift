// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "AIBubbleKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AIBubbleKit",
            targets: ["AIBubbleKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
        .package(url: "https://github.com/google/generative-ai-swift", from: "0.4.0"),
    ],
    targets: [
        .target(
            name: "AIBubbleKit",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "GoogleGenerativeAI", package: "generative-ai-swift"),
            ],
            path: "Sources"
        ),
    ]
)
