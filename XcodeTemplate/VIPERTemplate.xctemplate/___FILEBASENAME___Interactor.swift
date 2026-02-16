//___FILEHEADER___

import Foundation
import SwiftfulUtilities

@MainActor
protocol ___VARIABLE_productName:identifier___InteractorProtocol {
    func trackEvent(event: any LoggableEvent)
    // Add interactor methods here
}

@MainActor
final class ___VARIABLE_productName:identifier___Interactor {

    private let logManager: LogManager?

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)
        // Resolve additional dependencies here
    }
}

extension ___VARIABLE_productName:identifier___Interactor: ___VARIABLE_productName:identifier___InteractorProtocol {

    func trackEvent(event: any LoggableEvent) {
        logManager?.trackEvent(event: event)
    }

    // Implement interactor methods here
}
