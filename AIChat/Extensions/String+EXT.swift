//
//  String+EXT.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 25.06.2025.
//

import Foundation

extension String {
    
    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        replacingOccurrences(of: " ", with: "_")
    }
}

extension String {
    static func convertToString(_ value: Any) -> String? {
        switch value {
        case let value as String:
            value
        case let value as Int:
            String(value)
        case let value as Double:
            String(value)
        case let value as Float:
            String(value)
        case let value as Bool:
            value.description
        case let value as Date:
            value.formatted(date: .abbreviated, time: .shortened)
        case let array as [Any]:
            array.compactMap { value in
                convertToString(value)
            }
            .sorted()
            .joined(separator: ", ")
        case let value as CustomStringConvertible:
            value.description
        default:
            nil
        }
    }
}

extension String {
    var stableHashValue: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
}
