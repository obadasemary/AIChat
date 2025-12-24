//
//  AboutInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 01.12.2025.
//

import Foundation
import SwiftfulUtilities

@MainActor
protocol AboutInteractorProtocol {
    var appVersion: String { get }
    var buildNumber: String { get }
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class AboutInteractor {

    private let logManager: LogManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
    }
}

extension AboutInteractor: AboutInteractorProtocol {

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
