//
//  AvatarAttributes.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.06.2025.
//

import Foundation

enum CharacterOption: String, CaseIterable, Hashable, Codable {
    case man, woman, alien, dog, cat, robot
    case lawyer
    case criminalLawyer = "criminal lawyer"
    case strategist
    case consultant

    static var `default`: Self { .robot }
    
    var plural: String {
        switch self {
        case .man:
            "men"
        case .woman:
            "women"
        case .alien:
            "aliens"
        case .dog:
            "dogs"
        case .cat:
            "cats"
        case .robot:
            "robots"
        case .lawyer:
            "lawyers"
        case .criminalLawyer:
            "criminal lawyers"
        case .strategist:
            "strategists"
        case .consultant:
            "consultants"
        }
    }
    
    var startsWithVowel: Bool {
        switch self {
        case .woman, .alien:
            return true
        default:
            return false
        }
    }
}

enum CharacterAction: String, CaseIterable, Hashable, Codable {
    case smiling, sitting, eating, drinking, walking, running, jumping, sleeping, shopping, studying, working, relaxing, fighting, kissing, hugging, crying, laughing
    case consulting, presenting, negotiating, meeting, analyzing, advising, reviewing

    static var `default`: Self { .fighting }
}

enum CharacterLocation: String, CaseIterable, Hashable, Codable {
    case park, mall, museum, city, mountain, desert, forest, beach, ocean, space
    
    static var `default`: Self { .space }
}

struct AvatarDescriptionBuilder: Codable {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(
        characterOption: CharacterOption,
        characterAction: CharacterAction,
        characterLocation: CharacterLocation
    ) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init (avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    enum CodingKeys: String, CodingKey {
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
    }
    
    var characterDescription: String {
        let prefix = characterOption.rawValue.indefiniteArticle
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"
    }
    
    var eventParameters: [String: Any] {
        [
            CodingKeys.characterOption.rawValue: characterOption.rawValue,
            CodingKeys.characterAction.rawValue: characterAction.rawValue,
            CodingKeys.characterLocation.rawValue: characterLocation.rawValue,
            "character_description": characterDescription
        ]
    }
}
