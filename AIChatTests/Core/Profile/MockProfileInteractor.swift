//
//  MockProfileInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.07.2025.
//

import Foundation
@testable import AIChat

@MainActor
struct MockProfileInteractor: ProfileInteractor {
    
    var logger = MockLogService()
    var user: UserModel = UserModel.mock
    var avatars: [AvatarModel] = AvatarModel.mocks
    
    var currentUser: AIChat.UserModel? {
        user
    }
    
    func getAuthId() throws -> String {
        user.userId
    }
    
    func getAvatarsForAuthor(userId: String) async throws -> [AIChat.AvatarModel] {
        avatars
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        
    }
    
    func trackEvent(event: any AIChat.LoggableEvent) {
        logger.trackEvent(event: event)
    }
}
