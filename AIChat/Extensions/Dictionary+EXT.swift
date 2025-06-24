//
//  File.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 22.06.2025.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    
    var asAlphabeticalArray: [(key: String, value: Any)] {
        self
            .map { key, value in
                (key: key, value: value)
            }
            .sortedByKeyPath(keyPath: \.key)
    }
}

extension Dictionary where Key == String {
    
    mutating func first(upTo maxItems: Int) {
        var counter: Int = 0
        for (key, _) in self {
            if counter >= maxItems {
                removeValue(forKey: key)
            } else {
                counter += 1
            }
        }
    }
}
