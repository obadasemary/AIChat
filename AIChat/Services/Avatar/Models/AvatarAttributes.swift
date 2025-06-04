//
//  AvatarAttributes.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.06.2025.
//

import Foundation

enum CharacterOption: String, CaseIterable, Hashable {
    case man, woman, alien, dog, cat, robot
    
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

enum CharacterAction: String, CaseIterable, Hashable {
    case smiling, sitting, eating, drinking, walking, running, jumping, sleeping, shopping, studying, working, relaxing, fighting, kissing, hugging, crying, laughing
    
    static var `default`: Self { .fighting }
}

enum CharacterLocation: String, CaseIterable, Hashable {
    case park, mall, museum, city, mountain, desert, forest, beach, ocean, space
    
    static var `default`: Self { .space }
}

struct AvatarDescriptionBuilder {
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
    
    var characterDescription: String {
        let prefix = characterOption.rawValue.indefiniteArticle
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)"
    }
}
