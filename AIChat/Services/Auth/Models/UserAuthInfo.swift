//
//  UserAuthInfo.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.06.2025.
//

import Foundation

struct UserAuthInfo: Sendable, Codable {
    
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSignInDate: Date?
    let providerIDs: [String]
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSignInDate: Date? = nil,
        providerIDs: [String] = []
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSignInDate = lastSignInDate
        self.providerIDs = providerIDs
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "created_at"
        case lastSignInDate = "last_sign_in_at"
        case providerIDs = "provider_ids"
    }
    
    static func mock(isAnonymous: Bool = false) -> Self {
        UserAuthInfo(
            uid: "mock_user_123",
            email: "ai@example.com",
            isAnonymous: isAnonymous,
            creationDate: .now,
            lastSignInDate: .now,
            providerIDs: isAnonymous ? ["anonymous"] : ["google.com"]
        )
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "uauth_\(CodingKeys.uid.rawValue)": uid,
            "uauth_\(CodingKeys.email.rawValue)": email,
            "uauth_\(CodingKeys.isAnonymous.rawValue)": isAnonymous,
            "uauth_\(CodingKeys.creationDate.rawValue)": creationDate,
            "uauth_\(CodingKeys.lastSignInDate.rawValue)": lastSignInDate,
            "uauth_\(CodingKeys.providerIDs.rawValue)": providerIDs.joined(separator: ",")
        ]
        return dict.compactMapValues { $0 }
    }
    
    var hasAppleLinked: Bool {
        providerIDs.contains("apple.com")
    }
    
    var hasGoogleLinked: Bool {
        providerIDs.contains("google.com")
    }
}
