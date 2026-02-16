//___FILEHEADER___

import Foundation
import SwiftfulUtilities

@MainActor
protocol ___VARIABLE_productName:identifier___UseCaseProtocol {
    func trackEvent(event: any LoggableEvent)
    // Add use case methods here
}

@MainActor
final class ___VARIABLE_productName:identifier___UseCase {

    private let logManager: LogManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
        // Resolve additional dependencies here
    }
}

extension ___VARIABLE_productName:identifier___UseCase: ___VARIABLE_productName:identifier___UseCaseProtocol {

    func trackEvent(event: any LoggableEvent) {
        logManager?.trackEvent(event: event)
    }

    // Implement use case methods here
}
