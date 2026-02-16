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
            viewModel: ___VARIABLE_productName:identifier___ViewModel(
                ___VARIABLE_camelCasedProductName:identifier___UseCase: ___VARIABLE_productName:identifier___UseCase(container: container),
                router: ___VARIABLE_productName:identifier___Router(router: router)
            )
        )
    }
}
