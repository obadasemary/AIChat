//___FILEHEADER___

import SwiftUI
import SUIRouting

@Observable
@MainActor
final class ___VARIABLE_productName:identifier___Builder {
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func build___VARIABLE_productName:identifier___View(router: Router) -> some View {
        ___VARIABLE_productName:identifier___View(
            presenter: ___VARIABLE_productName:identifier___Presenter(
                ___VARIABLE_camelCasedProductName:identifier___Interactor: ___VARIABLE_productName:identifier___Interactor(container: container),
                router: ___VARIABLE_productName:identifier___Router(router: router)
            )
        )
    }
}
