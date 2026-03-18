//
//  String+EXT.swift
//  SamuraiLoggingFirebaseAnalytics
//
//  Created by Abdelrahman Mohamed on 18.03.2026.
//

import Foundation

extension String {
    
    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        replacingOccurrences(of: " ", with: "_")
    }
    
    func clean(maxCharacters: Int) -> String {
        self
            .clipped(maxCharacters: 40)
            .replaceSpacesWithUnderscores()
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
