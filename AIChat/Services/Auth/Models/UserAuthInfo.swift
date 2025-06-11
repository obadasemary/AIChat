//
//  UserAuthInfo.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.06.2025.
//

import Foundation


struct UserAuthInfo: Sendable {
    let uid: String
    let name: String?
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?
    let displayName: String?
    
    init(
        uid: String,
        name: String? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        displayName: String? = nil
    ) {
        self.uid = uid
        self.name = name
        self.email = email
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.displayName = displayName
    }
    
    static func mock(isAnonymous: Bool = false) -> Self {
        UserAuthInfo(
            uid: "mock_user_123",
            name: "aichatname",
            email: "ai@example.com",
            photoUrl: "example.com",
            isAnonymous: isAnonymous,
            creationDate: .now,
            lastSignInDate: .now,
            displayName: "aichatname"
        )
    }
}
