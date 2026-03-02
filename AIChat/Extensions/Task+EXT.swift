//
//  Task+EXT.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 02.03.2026.
//

extension Task where Success == Void, Failure == Error {
    /// A no-op task that completes immediately, useful as a guard-clause return value
    /// when a function is declared `@discardableResult` and returns `Task<Void, Error>`.
    ///
    /// This is a computed property — a new `Task` is allocated on every access.
    /// Tasks cannot be reused, so there is no caching benefit to using `static let`.
    static var noop: Task {
        Task {}
    }
}

extension Task where Success == Void, Failure == Never {
    /// A no-op task that completes immediately, useful as a guard-clause return value
    /// when a function is declared `@discardableResult` and returns `Task<Void, Never>`.
    ///
    /// This is a computed property — a new `Task` is allocated on every access.
    /// Tasks cannot be reused, so there is no caching benefit to using `static let`.
    static var noop: Task {
        Task {}
    }
}
