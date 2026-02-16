//
//  Dictionary+Logging.swift
//  LoggingService
//

import Foundation

package extension Dictionary where Key == String {

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
