---
name: ios-clean-architecture
description: Modular Clean Architecture template for iOS apps built with SwiftUI and Swift Package Manager on Swift 6.2 with default main-actor isolation. Use when scaffolding a new iOS feature, organizing a SwiftUI app into layered SPM packages (NetworkService, Endpoints, Repositories, UseCases, DIContainer, feature views), applying protocol-first cross-module dependencies, wiring up Builder-based feature instantiation, or migrating ObservableObject code to @Observable with Swift 6 concurrency and Swift Testing.
---

# iOS Clean Architecture (SwiftUI + SPM, Swift 6.2)

This template provides a modular Clean Architecture pattern for iOS apps built with Swift 6.2 and SwiftUI. Here are the key characteristics:

## Core Architecture

The template follows a layered dependency structure where "outer layers depend on inner layers, never the reverse." Data flows unidirectionally from user interactions through ViewModels → UseCases → Repositories → NetworkServices.

## Key Technologies & Patterns

- **Swift 6.2 with default actor isolation** — main-actor isolation applies automatically to all types unless explicitly marked otherwise
- **SwiftUI with @Observable** — replaces the older `@Published` / `ObservableObject` pattern
- **Swift Package Manager** — multi-module organization keeps concerns separated
- **Protocol-first design** — cross-module dependencies always use protocols, never concrete types
- **Builder pattern** — mandatory feature instantiation through dedicated builders
- **Service-locator DIContainer** — centralized dependency registration and resolution

## Module Organization

Each responsibility occupies its own SPM package: NetworkService, Endpoints, Repositories, UseCases, DependencyContainer, feature-specific View packages, shared UI components, and preview utilities.

## Testing Approach

The template uses Swift Testing (not XCTest) with test doubles: MockNetworkService, FakeFeedUseCase, and SpyRouter classes that enable isolation of components during verification.

## Critical Constraints

Do not write `@MainActor` manually in Swift 6.2 targets with default isolation enabled. Avoid force unwrapping except within Builder internals. Never allow ViewModels to call URLSession or Repositories directly—route through UseCases. Use `.xcworkspace`, not `.xcodeproj` alone.
