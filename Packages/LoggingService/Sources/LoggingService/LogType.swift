//
//  LogType.swift
//  LoggingService
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

    public var osLogType: OSLogType {
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
