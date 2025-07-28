//
//  ExploreInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol ExploreInteractor {
    var categoryRowTest: CategoryRowTestOption { get }
    var createAccountTest: Bool { get }
    
    var auth: UserAuthInfo? { get }
    
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    
    func trackEvent(event: LoggableEvent)
    func schedulePushNotificationForTheNextWeek()
    func canRequestAuthorization() async -> Bool
    func reuestAuthorization() async throws -> Bool
}

extension CoreInteractor: ExploreInteractor {}
