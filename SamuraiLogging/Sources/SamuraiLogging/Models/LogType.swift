//
//  LogType.swift
//  SamuraiLogging
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import OSLog

public enum LogType: Sendable {
    /// Use 'info' for informative tasks, These are not considered analytics, issues, or errors.
    case info
    /// Default type for analytics.
    case analytic
    /// Issues or errors that should not occur, but will not negatively affect the user experience.
    case warning
    /// Issues or errors that negatively affect user experience.
    case severe

    public var emoji: String {
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
    
    var asString: String {
        switch self {
        case .info: return "info"
        case .analytic: return "analytic"
        case .warning: return "warning"
        case .severe: return "severe"
        }
    }

    
}
