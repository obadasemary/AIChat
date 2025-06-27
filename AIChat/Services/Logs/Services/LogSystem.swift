//
//  LogSystem.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import Foundation
import OSLog

actor LogSystem {
    
    // swiftlint:disable force_unwrapping
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "ConsoleLogger"
    )
    // swiftlint:enable force_unwrapping
    
    func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }
    
    nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.OsLogType, message: message)
        }
    }
}

enum LogType {
    /// Use 'info' for informative tasks, These are not considered analytics, issues, or errors.
    case info
    /// Default type for analytics.
    case analytic
    /// Issues or errors that should not occur, but will not negatively affect the user experience.
    case warning
    /// Issues or errors that negatively affect user experience.
    case severe
    
    var emoji: String {
        switch self {
        case .info:
            "🚀🚀🚀"
        case .analytic:
            "📊📊📊"
        case .warning:
            "⚠️⚠️⚠️"
        case .severe:
            "🚨🚨🚨"
        }
    }
    
    var OsLogType: OSLogType {
        switch self {
        case .info:
                .info
        case .analytic:
                .default
        case .warning:
                .error
        case .severe:
                .fault
        }
    }
}
