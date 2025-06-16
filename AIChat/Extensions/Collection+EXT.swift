//
//  Collection+EXT.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.06.2025.
//

import Foundation

extension Collection {
    
    func first(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        
        let maxItems = Swift.min(count, value)
        return Array(prefix(maxItems))
    }
    
    func last(upTo value: Int) -> [Element]? {
        guard !isEmpty else { return nil }
        
        let maxItems = Swift.min(count, value)
        return Array(suffix(maxItems))
    }
}
