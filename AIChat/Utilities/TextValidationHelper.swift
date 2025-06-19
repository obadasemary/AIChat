//
//  TextValidationError.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.06.2025.
//

import Foundation

struct TextValidationHelper {
    static func checkIfTextIsValid(text: String, minimumCharactersCount: Int = 3) throws {
        guard text.count >= minimumCharactersCount else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharactersCount)
        }
        
//        let badWords: [String] = ["bad", "word"]
//        
//        if badWords.contains(where: text.lowercased().contains) {
//            throw TextValidationError.hasBadWords
//        }
    }
    
    enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int)
        case hasBadWords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                return "Your message should contain at least \(min) characters."
            case .hasBadWords:
                return "Your message contains inappropriate words."
            }
        }
    }
}
