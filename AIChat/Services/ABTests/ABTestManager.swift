//
//  ABTestManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.07.2025.
//

import Foundation

@MainActor
@Observable
class ABTestManager {
    
    private let service: ABTestServiceProtocol
    private let logManager: LogManagerProtocol?
    
    var activeTests: ActiveABTests
    
    init(
        service: ABTestServiceProtocol,
        logManager: LogManagerProtocol? = nil
    ) {
        self.service = service
        self.logManager = logManager
        self.activeTests = service.activeTests
        self.configure()
    }
    
}

extension ABTestManager: @preconcurrency ABTestManagerProtocol {
    
    func override(updateTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTest: updateTests)
        configure()
    }
}

private extension ABTestManager {
    
    func configure() {
        Task {
            do {
                activeTests = try await service.fetchUpdatedConfig()
                logManager?
                    .trackEvent(
                        event: Event.fetchRemoteConfigSuccess
                    )
                logManager?
                    .addUserProperties(
                        dict: activeTests.eventParameters,
                        isHighPriority: false
                    )
            } catch {
                logManager?
                    .trackEvent(
                        event: Event.fetchRemoteConfigFailure(error: error)
                    )
            }
        }
    }
}

private extension ABTestManager {
    
    enum Event: LoggableEvent {
        case fetchRemoteConfigSuccess
        case fetchRemoteConfigFailure(error: Error)
        
        var eventName: String {
            switch self {
            case .fetchRemoteConfigSuccess: "ABManager_FetchRemoteConfigSuccess"
            case .fetchRemoteConfigFailure: "ABManager_FetchRemoteConfigFailure"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .fetchRemoteConfigFailure(error: let error):
                error.eventParameters
            default:
                nil
            }
        }
        
        var type: LogType {
            switch self {
            case .fetchRemoteConfigFailure:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
