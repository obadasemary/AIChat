//
//  LogType+OSLog.swift
//  SamuraiLogging
//
//  Created by Abdelrahman Mohamed on 15.03.2026.
//

import OSLog

extension LogType {
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

