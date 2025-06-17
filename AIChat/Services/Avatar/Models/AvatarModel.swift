//
//  AvatarModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 08.04.2025.
//

import Foundation
import IdentifiableByString

struct AvatarModel: Hashable, Codable, StringIdentifiable {
    
    var id: String { avatarId }
    
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorId: String?
    let dateCreated: Date?
    let clickCount: Int?
    
    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil,
        clickCount: Int? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
        self.clickCount = clickCount
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorId = "author_id"
        case dateCreated = "date_created"
        case clickCount = "click_count"
    }
    
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).characterDescription
    }
    
    mutating func updateProfileImage(imageName: String) {
        profileImageName = imageName
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    static var mocks: [Self] {
        [
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Alpha",
                characterOption: .alien,
                characterAction: .smiling,
                characterLocation: .park,
                profileImageName: Constants.randomImage,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 10
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Beta",
                characterOption: .dog,
                characterAction: .drinking,
                characterLocation: .forest,
                profileImageName: Constants.randomImage,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 100
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Gamma",
                characterOption: .cat,
                characterAction: .eating,
                characterLocation: .museum,
                profileImageName: Constants.randomImage,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 5
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Delta",
                characterOption: .woman,
                characterAction: .shopping,
                characterLocation: .mall,
                profileImageName: Constants.randomImage,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 50
            ),
            AvatarModel(
                avatarId: UUID().uuidString,
                name: "Zeta",
                characterOption: .robot,
                characterAction: .jumping,
                characterLocation: .mountain,
                profileImageName: Constants.randomImage,
                authorId: UUID().uuidString,
                dateCreated: .now,
                clickCount: 30
            )
        ]
    }
}
