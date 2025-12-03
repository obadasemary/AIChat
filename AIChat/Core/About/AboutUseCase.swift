//
//  AboutUseCase.swift
//  AIChat
//
//  Created by Claude Code on 01.12.2025.
//

import Foundation
import SwiftfulUtilities

@MainActor
protocol AboutUseCaseProtocol {
    var appVersion: String { get }
    var buildNumber: String { get }
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class AboutUseCase {

    private let logManager: LogManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
    }
}

extension AboutUseCase: AboutUseCaseProtocol {

    var appVersion: String {
        Utilities.appVersion ?? "Unknown"
    }

    var buildNumber: String {
        Utilities.buildNumber ?? "Unknown"
    }

    func trackEvent(event: any LoggableEvent) {
        logManager?.trackEvent(event: event)
    }
}
