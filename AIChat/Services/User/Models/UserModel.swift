//
//  UserModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.05.2025.
//

import Foundation
import SwiftUI

struct UserModel {
    
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date?,
        didCompleteOnboarding: Bool?,
        profileColorHex: String?
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    var profileColorCalculated: Color {
        guard let profileColorHex else { return .accent }
        return Color(hex: profileColorHex)
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            UserModel(
                userId: "mock_user_id_1",
                dateCreated: now,
                didCompleteOnboarding: true,
                profileColorHex: "#FF5733"
            ),
            UserModel(
                userId: "mock_user_id_2",
                dateCreated: now.addingTimeInterval(days: -1),
                didCompleteOnboarding: false,
                profileColorHex: "#33ADFF"
            ),
            UserModel(
                userId: "mock_user_id_3",
                dateCreated: now.addingTimeInterval(days: -3, hours: -2),
                didCompleteOnboarding: true,
                profileColorHex: "#7DCEA0"
            ),
            UserModel(
                userId: "mock_user_id_4",
                dateCreated: now
                    .addingTimeInterval(days: -5, hours: -4, minutes: -33),
                didCompleteOnboarding: nil,
                profileColorHex: "#FF33A1"
            ),
        ]
    }
}
