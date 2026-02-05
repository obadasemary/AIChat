//
//  AdminViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class AdminViewModel {

    private let ___VARIABLE_camelCasedProductName:identifier___UseCase: AdminUseCaseProtocol
    private let router: AdminRouterProtocol

    init(
        ___VARIABLE_camelCasedProductName:identifier___UseCase: AdminUseCaseProtocol,
        router: AdminRouterProtocol
    ) {
        self.___VARIABLE_camelCasedProductName:identifier___UseCase = ___VARIABLE_camelCasedProductName:identifier___UseCase
        self.router = router
    }
}

// MARK: - Actions
extension AdminViewModel {

    // Add user action methods here
}

// MARK: - Event
private extension AdminViewModel {

    enum Event: LoggableEvent {
        case exampleEvent

        var eventName: String {
            switch self {
            case .exampleEvent: "AdminView_Example_Event"
            }
        }

        var parameters: [String: Any]? {
            return nil
        }

        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
