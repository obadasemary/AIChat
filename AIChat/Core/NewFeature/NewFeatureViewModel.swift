//
//  NewFeatureViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class NewFeatureViewModel {

    private let ___VARIABLE_camelCasedProductName:identifier___UseCase: NewFeatureUseCaseProtocol
    private let router: NewFeatureRouterProtocol

    init(
        ___VARIABLE_camelCasedProductName:identifier___UseCase: NewFeatureUseCaseProtocol,
        router: NewFeatureRouterProtocol
    ) {
        self.___VARIABLE_camelCasedProductName:identifier___UseCase = ___VARIABLE_camelCasedProductName:identifier___UseCase
        self.router = router
    }
}

// MARK: - Actions
extension NewFeatureViewModel {

    // Add user action methods here
}

// MARK: - Event
private extension NewFeatureViewModel {

    enum Event: LoggableEvent {
        case exampleEvent

        var eventName: String {
            switch self {
            case .exampleEvent: "NewFeatureView_Example_Event"
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
