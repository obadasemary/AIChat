//
//  Helper.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 09.04.2025.
//

import Foundation

extension String {
    var indefiniteArticle: String {
        let lowercasedWord = self.lowercased()
        
        let specialAnWords: Set<String> = [
            "hour", "honest", "honor", "heir", "herb"
        ]
        
        let specialAWords: Set<String> = [
            "university", "unicorn", "unique", "europe", "european", "user", "one", "once"
        ]
        
        if specialAnWords.contains(lowercasedWord) {
            return "An"
        } else if specialAWords.contains(lowercasedWord) {
            return "A"
        }
        
        guard let firstChar = lowercasedWord.first else {
            return "A"
        }
        
        let vowels: Set<Character> = ["a", "e", "i", "o", "u"]
        return vowels.contains(firstChar) ? "An" : "A"
    }
}
