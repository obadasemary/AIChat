//
//  LogSystem.swift
//  LoggingService
//

import Foundation
import OSLog

public actor LogSystem {

    // swiftlint:disable force_unwrapping
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "ConsoleLogger"
    )
    // swiftlint:enable force_unwrapping

    public init() {}

    public func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }

    public nonisolated func log(level: LogType, message: String) {
        Task {
            await log(level: level.osLogType, message: message)
        }
    }
}
