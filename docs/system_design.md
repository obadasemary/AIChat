# System Design

This document outlines the system architecture and design of the AIChat application using Mermaid.js diagrams.

## 1. High-Level Architecture

AIChat follows **Clean Architecture** principles with **MVVM** pattern. The application is structured into three main layers: Presentation (View & ViewModel), Domain (UseCase), and Data (Manager & Service).

```mermaid
graph TD
    subgraph "Presentation Layer"
        View[SwiftUI View]
        ViewModel[ViewModel]
    end

    subgraph "Domain Layer"
        UseCase[UseCase]
    end

    subgraph "Data Layer"
        Manager[Manager Protocol]
        Service[Service Implementation]
        Repo[Repository / Data Source]
    end

    subgraph "External Services"
        OpenAI[OpenAI API]
        Firebase[Firebase Auth/DB]
        Mixpanel[Mixpanel Analytics]
    end

    View -->|User Action| ViewModel
    ViewModel -->|State Update| View
    ViewModel -->|Business Logic| UseCase
    UseCase -->|Request Data| Manager
    Manager -->|Call API| Service
    Service -->|Network Request| ExternalServices

    Service -.->|Concrete Impl| Manager
    
    linkStyle default stroke-width:2px,fill:none,stroke:gray;
```

## 2. Message Flow Sequence Diagram

This diagram illustrates the end-to-end flow when a user sends a chat message.

```mermaid
sequenceDiagram
    participant User
    participant View as ChatView
    participant VM as ChatViewModel
    participant UC as ChatUseCase
    participant CM as ChatManager
    participant AI as OpenAIServer
    participant API as OpenAI API

    User->>View: Taps Send Button
    View->>VM: sendMessage(text)
    VM->>UC: sendMessage(text)
    
    par Save User Message
        UC->>CM: saveMessage(userMessage)
    and Request AI Response
        UC->>CM: getAIResponse(history)
    end

    CM->>AI: generateCompletion(messages)
    AI->>API: POST /v1/chat/completions
    activate API
    API-->>AI: Streamed Response Chunks
    deactivate API
    
    loop Stream Processing
        AI-->>CM: Yield Chunk
        CM-->>UC: Yield Chunk
        UC-->>VM: Update Current Message
        VM-->>View: Update UI (Streaming)
    end

    AI-->>CM: Completion Finished
    CM-->>UC: Completion Finished
    UC->>CM: saveMessage(aiResponse)
    UC-->>VM: Final State Update
    VM-->>View: Ready State
```

## 3. Core Components Class Diagram

This diagram shows the relationships between the Dependency Container, Protocols, and Concrete Implementations, highlighting the Dependency Injection pattern.

```mermaid
classDiagram
    class DependencyContainer {
        +register(type, factory)
        +resolve(type)
    }

    class AppDependencies {
        +configure(container, config)
    }

    class ConfigurationManager {
        +apiKey: String
        +environment: AppEnvironment
    }

    %% Protocols
    class AIManager {
        <<interface>>
        +generateCompletion()
    }
    class AuthManager {
        <<interface>>
        +signIn()
        +signOut()
    }
    class AnalyticsService {
        <<interface>>
        +trackEvent()
    }

    %% Implementations
    class OpenAIServer {
        -apiKey: String
        +generateCompletion()
    }
    class MockAIServer {
        +generateCompletion()
    }
    
    class FirebaseAuthService {
        +signIn()
    }
    class MockAuthService {
        +signIn()
    }

    %% Relationships
    AppDependencies ..> DependencyContainer : Configures
    AppDependencies ..> ConfigurationManager : Reads Config
    
    OpenAIServer ..|> AIManager : Implements
    MockAIServer ..|> AIManager : Implements
    
    FirebaseAuthService ..|> AuthManager : Implements
    MockAuthService ..|> AuthManager : Implements

    DependencyContainer o-- AIManager : Manages
    DependencyContainer o-- AuthManager : Manages
```
