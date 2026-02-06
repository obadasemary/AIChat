//
//  TokenUsageViewModel.swift
//  AIChat
//
//  Created by OpenAI on 2026-02-18.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
final class TokenUsageViewModel {

    private let useCase: TokenUsageUseCaseProtocol
    private let router: TokenUsageRouterProtocol

    private(set) var entries: [TokenUsageEntry] = []
    private(set) var isLoading = false
    private(set) var lastUpdated: Date?

    init(
        useCase: TokenUsageUseCaseProtocol,
        router: TokenUsageRouterProtocol
    ) {
        self.useCase = useCase
        self.router = router
    }
}

// MARK: - Data
extension TokenUsageViewModel {

    func loadUsage() async {
        isLoading = true
        defer { isLoading = false }

        do {
            entries = try await useCase.fetchUsage()
            lastUpdated = Date()
            useCase.trackEvent(event: Event.loadUsageSuccess)
        } catch {
            useCase.trackEvent(event: Event.loadUsageFail(error: error))
            router.showAlert(error: error)
        }
    }

    func refreshTapped() {
        useCase.trackEvent(event: Event.refreshTapped)
        Task {
            await loadUsage()
        }
    }
}

// MARK: - Events
private extension TokenUsageViewModel {

    enum Event: LoggableEvent {
        case loadUsageSuccess
        case loadUsageFail(error: Error)
        case refreshTapped

        var eventName: String {
            switch self {
            case .loadUsageSuccess:
                return "TokenUsage_Load_Success"
            case .loadUsageFail:
                return "TokenUsage_Load_Fail"
            case .refreshTapped:
                return "TokenUsage_Refresh_Tapped"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadUsageFail(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadUsageFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
