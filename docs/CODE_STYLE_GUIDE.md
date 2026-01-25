# Code Style Guide

Swift coding standards and best practices for AIChat development.

## Table of Contents

1. [General Principles](#general-principles)
2. [Naming Conventions](#naming-conventions)
3. [Code Organization](#code-organization)
4. [SwiftUI Guidelines](#swiftui-guidelines)
5. [Architecture Patterns](#architecture-patterns)
6. [Error Handling](#error-handling)
7. [Async/Await](#asyncawait)
8. [Documentation](#documentation)
9. [SwiftLint Rules](#swiftlint-rules)

---

## General Principles

### Clarity Over Brevity
Write code that is easy to understand. Prefer explicit over implicit.

```swift
// Good - Clear intent
let userDisplayName = user.firstName + " " + user.lastName

// Avoid - Unclear
let n = u.f + " " + u.l
```

### Consistency
Follow established patterns in the codebase. When in doubt, look at existing code.

### Simplicity
Avoid over-engineering. Write the simplest code that solves the problem.

---

## Naming Conventions

### Types (Classes, Structs, Enums, Protocols)
Use PascalCase:
```swift
struct UserModel { }
class ChatViewModel { }
enum ChatRole { }
protocol AuthManagerProtocol { }
```

### Variables and Functions
Use camelCase:
```swift
let userName: String
var isLoggedIn: Bool
func fetchUserProfile() { }
```

### Constants
Use camelCase for instance constants, PascalCase for type constants:
```swift
let maximumRetryCount = 3

struct Constants {
    static let APIBaseURL = "https://api.example.com"
}
```

### Boolean Variables
Use `is`, `has`, `should`, `can`, `did`, `will` prefixes:
```swift
var isLoading: Bool
var hasUnreadMessages: Bool
var shouldShowOnboarding: Bool
var canSendMessage: Bool
var didCompleteOnboarding: Bool
```

### Protocols
- Use `-able`, `-ible` suffix for capabilities: `Codable`, `Identifiable`
- Use `Protocol` suffix for delegate/service protocols: `AuthManagerProtocol`
- Use `Delegate` suffix for delegates: `ChatDelegate`

### File Names
Match the primary type name:
```
ChatViewModel.swift       // Contains ChatViewModel class
UserModel.swift          // Contains UserModel struct
AuthManagerProtocol.swift // Contains AuthManagerProtocol
```

---

## Code Organization

### File Structure
Organize files by feature, not by type:
```
Core/
  Chat/
    ChatView.swift
    ChatViewModel.swift
    ChatUseCase.swift
    ChatBuilder.swift
    ChatRouter.swift
```

### Type Organization
Use MARK comments to organize code:
```swift
class ChatViewModel {

    // MARK: - Properties

    private let useCase: ChatUseCaseProtocol
    private(set) var messages: [ChatMessageModel] = []

    // MARK: - Initialization

    init(useCase: ChatUseCaseProtocol) {
        self.useCase = useCase
    }

    // MARK: - Public Methods

    func loadMessages() async { }

    // MARK: - Private Methods

    private func processMessage(_ message: ChatMessageModel) { }
}
```

### Extension Organization
Use extensions to group related functionality:
```swift
// MARK: - Load
extension ChatViewModel {
    func loadChat() async { }
    func loadMessages() async { }
}

// MARK: - Actions
extension ChatViewModel {
    func sendMessage() { }
    func deleteMessage() { }
}
```

---

## SwiftUI Guidelines

### View Structure
Keep views simple and delegate logic to ViewModels:
```swift
struct ChatView: View {
    @State private var viewModel: ChatViewModel

    var body: some View {
        VStack {
            messagesList
            inputField
        }
        .task {
            await viewModel.loadMessages()
        }
    }

    // MARK: - Subviews

    private var messagesList: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.messages) { message in
                    MessageRow(message: message)
                }
            }
        }
    }

    private var inputField: some View {
        TextField("Message", text: $viewModel.messageText)
    }
}
```

### Property Wrappers Order
```swift
struct MyView: View {
    // Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(ChatBuilder.self) var chatBuilder

    // State
    @State private var viewModel: MyViewModel

    // Binding
    @Binding var isPresented: Bool

    // Other properties
    let title: String
}
```

### Prefer Computed Properties for Derived Views
```swift
private var submitButton: some View {
    Button("Submit") {
        viewModel.submit()
    }
    .disabled(!viewModel.canSubmit)
}
```

---

## Architecture Patterns

### MVVM Structure
```swift
// View - UI only
struct FeatureView: View {
    @State private var viewModel: FeatureViewModel
    var body: some View { /* UI */ }
}

// ViewModel - Presentation logic
@Observable
class FeatureViewModel {
    private let useCase: FeatureUseCaseProtocol
    // State properties
    // Action methods
}

// UseCase - Business logic
class FeatureUseCase: FeatureUseCaseProtocol {
    private let container: DependencyContainer
    // Business methods
}

// Builder - Dependency injection
@Observable
class FeatureBuilder {
    let container: DependencyContainer

    func buildFeatureView() -> some View {
        FeatureView(
            viewModel: FeatureViewModel(
                useCase: FeatureUseCase(container: container)
            )
        )
    }
}
```

### Dependency Resolution
Always use DependencyContainer:
```swift
// Good
let authManager = container.resolve(AuthManager.self)

// Bad - Don't create services directly
let authManager = AuthManager(service: FirebaseAuthService())
```

---

## Error Handling

### Never Use Force Unwrapping
```swift
// Bad - SwiftLint error
let value = optionalValue!

// Good
guard let value = optionalValue else {
    throw MyError.valueNotFound
}
```

### Never Use Force Try
```swift
// Bad - SwiftLint error
let data = try! decoder.decode(Model.self, from: json)

// Good
do {
    let data = try decoder.decode(Model.self, from: json)
} catch {
    logger.log("Decoding failed: \(error)")
    throw error
}
```

### Use Custom Error Types
```swift
enum ChatError: LocalizedError {
    case messageEmpty
    case sendFailed(underlying: Error)
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .messageEmpty:
            return "Message cannot be empty"
        case .sendFailed(let error):
            return "Failed to send: \(error.localizedDescription)"
        case .networkUnavailable:
            return "No network connection"
        }
    }
}
```

---

## Async/Await

### Use async/await Over Completion Handlers
```swift
// Good
func fetchUser() async throws -> UserModel {
    try await userManager.getUser(userId: userId)
}

// Avoid (legacy pattern)
func fetchUser(completion: @escaping (Result<UserModel, Error>) -> Void) {
    // ...
}
```

### Use Task for Async Work in Views
```swift
struct MyView: View {
    var body: some View {
        Text("Hello")
            .task {
                await viewModel.loadData()
            }
    }
}
```

### Mark ViewModels with @MainActor
```swift
@MainActor
@Observable
class MyViewModel {
    // All properties and methods run on main thread
}
```

---

## Documentation

### When to Document
- Public APIs
- Complex algorithms
- Non-obvious behavior
- Protocol requirements

### Documentation Style
```swift
/// Sends a message to the current chat.
///
/// This method validates the message, uploads it to Firebase,
/// and triggers an AI response generation.
///
/// - Parameter content: The message text to send.
/// - Throws: `ChatError.messageEmpty` if content is empty.
/// - Returns: The sent message model.
func sendMessage(content: String) async throws -> ChatMessageModel {
    // Implementation
}
```

### Don't Over-Document
```swift
// Bad - Obvious from the code
/// Returns the user's name
var userName: String { user.name }

// Good - No comment needed for simple properties
var userName: String { user.name }
```

---

## SwiftLint Rules

### Enforced Rules (Errors)

| Rule | Description |
|------|-------------|
| `force_unwrapping` | Never use `!` for unwrapping |
| `force_try` | Never use `try!` |
| `force_cast` | Never use `as!` |

### Style Rules

| Rule | Limit |
|------|-------|
| `line_length` | 160 characters |
| `function_body_length` | 50 lines |
| `type_body_length` | 400 lines |
| `file_length` | 500 lines |

### Indentation
Use 4 spaces (not tabs):
```swift
struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello")
        }
    }
}
```

### Disabling Rules
Only disable rules with explicit comment:
```swift
// swiftlint:disable force_unwrapping
let required = optional!
// swiftlint:enable force_unwrapping
```

---

## Test Naming

Use descriptive test names with `test_when_then` format:
```swift
func test_whenUserTapsSendButton_thenMessageIsSent() {
    // Given
    let viewModel = ChatViewModel(useCase: mockUseCase)
    viewModel.messageText = "Hello"

    // When
    viewModel.sendMessage()

    // Then
    XCTAssertTrue(mockUseCase.sendMessageCalled)
}
```

---

## Quick Reference

### Do's
- Use `guard` for early returns
- Use `@MainActor` for UI-related code
- Use dependency injection via container
- Write unit tests for business logic
- Follow existing patterns in codebase

### Don'ts
- Don't use force unwrapping (`!`)
- Don't use force try (`try!`)
- Don't create services directly
- Don't put business logic in views
- Don't ignore SwiftLint warnings
