//
//  FirebaseABTestService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.07.2025.
//

import Foundation
import FirebaseRemoteConfig

@MainActor
class FirebaseABTestService {
    var activeTests: ActiveABTests {
        ActiveABTests(config: RemoteConfig.remoteConfig())
    }
    
    init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        
        let defaultValue = ActiveABTests(
            createAccountTest: false,
            onboardingCommunityTest: false,
            categoryRowTest: .default
        )
        
        RemoteConfig
            .remoteConfig()
            .setDefaults(defaultValue.asNSObjectDictionary)
        RemoteConfig
            .remoteConfig()
            .activate()
    }
}

extension FirebaseABTestService: ABTestServiceProtocol {

    func saveUpdatedConfig(updatedTest: ActiveABTests) throws {
        assertionFailure("Error: Firebase AB Test are not configurable from the client.")
    }
    
    func fetchUpdatedConfig() async throws -> ActiveABTests {
        let status = try await RemoteConfig.remoteConfig().fetchAndActivate()
        
        switch status {
        case .successFetchedFromRemote, .successUsingPreFetchedData:
            return activeTests
        case .error:
            throw RemoteConfigError.failedToFetch
        @unknown default:
            throw RemoteConfigError.failedToFetch
        }
    }
    
    enum RemoteConfigError: LocalizedError {
        case failedToFetch
    }
}
