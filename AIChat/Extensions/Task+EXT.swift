//
//  Task+EXT.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

extension Task where Success == Void, Failure == Never {
    /// A no-op task that completes immediately, useful as a guard-clause return value
    /// when a function is declared `@discardableResult` and returns `Task<Void, Never>`.
    static var noop: Task {
        Task {}
    }
}
