//___FILEHEADER___

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class ___VARIABLE_productName:identifier___Presenter {

    private let ___VARIABLE_camelCasedProductName:identifier___Interactor: ___VARIABLE_productName:identifier___InteractorProtocol
    private let router: ___VARIABLE_productName:identifier___RouterProtocol

    init(
        ___VARIABLE_camelCasedProductName:identifier___Interactor: ___VARIABLE_productName:identifier___InteractorProtocol,
        router: ___VARIABLE_productName:identifier___RouterProtocol
    ) {
        self.___VARIABLE_camelCasedProductName:identifier___Interactor = ___VARIABLE_camelCasedProductName:identifier___Interactor
        self.router = router
    }
}

// MARK: - Actions
extension ___VARIABLE_productName:identifier___Presenter {

    // Add user action methods here
}

// MARK: - Event
private extension ___VARIABLE_productName:identifier___Presenter {

    enum Event: LoggableEvent {
        case exampleEvent

        var eventName: String {
            switch self {
            case .exampleEvent: "___VARIABLE_productName:identifier___View_Example_Event"
            }
        }

        var parameters: [String: Any]? {
            return nil
        }

        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
