//
//  Dictionary+EXT.swift
//  SamuraiLoggingFirebaseAnalytics
//
//  Created by Abdelrahman Mohamed on 18.03.2026.
//

import Foundation

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
