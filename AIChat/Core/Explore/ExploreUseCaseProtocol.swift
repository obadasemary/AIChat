//
//  ExploreUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import Foundation

@MainActor
protocol ExploreUseCaseProtocol {
    var categoryRowTest: CategoryRowTestOption { get }
    var createAccountTest: Bool { get }
    
    var auth: UserAuthInfo? { get }
    
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    
    func schedulePushNotificationForTheNextWeek()
    func canRequestAuthorization() async -> Bool
    func reuestAuthorization() async throws -> Bool
    
    func updateAppState(showTabBarView: Bool)
    func signOut() throws
    
    func trackEvent(event: LoggableEvent)
}
