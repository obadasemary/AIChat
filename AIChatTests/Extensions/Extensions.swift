//
//  Extensions.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 13.07.2025.
//

import Foundation

extension String {
    static var random: String {
        UUID().uuidString
    }
    
    static func randomHexColor() -> String {
        String(format: "#%06X", Int.random(in: 0..<0xFFFFFF))
    }
}

extension Date {
    static var random: Date {
        let randomTimeInterval: TimeInterval = TimeInterval.random(in: 0...2_000_000_000)
        return Date(timeIntervalSince1970: randomTimeInterval)
    }
    
    static func random(in range: Range<TimeInterval>) -> Date {
        let randomTimeInterval: TimeInterval = TimeInterval.random(in: range)
        return Date(timeIntervalSince1970: randomTimeInterval)
    }
    
    static func random(in range: ClosedRange<TimeInterval>) -> Date {
        let randomTimeInterval: TimeInterval = TimeInterval.random(in: range)
        return Date(timeIntervalSince1970: randomTimeInterval)
    }
    
    func truncatedToSeconds() -> Date {
        let timeInterval = floor(self.timeIntervalSince1970)
        return Date(timeIntervalSince1970: timeInterval)
    }
}
