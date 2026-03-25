//
//  LogSystem.swift
//  SamuraiLogging
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import OSLog

public actor LogSystem {

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "SamuraiLogging",
        category: "ConsoleLogger"
    )

    public init() {}

    public func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }

    public nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.OsLogType, message: message)
        }
    }
}
