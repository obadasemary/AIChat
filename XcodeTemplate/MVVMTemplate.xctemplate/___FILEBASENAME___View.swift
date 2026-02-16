//___FILEHEADER___

import SwiftUI

struct ___VARIABLE_productName:identifier___View: View {

    @State var viewModel: ___VARIABLE_productName:identifier___ViewModel

    var body: some View {
        Text("___VARIABLE_productName:identifier___ View")
            .navigationTitle("___VARIABLE_productName:identifier___")
            .screenAppearAnalytics(name: "___VARIABLE_productName:identifier___View")
    }
}

#Preview {
    let container = DevPreview.shared.container
    let ___VARIABLE_camelCasedProductName:identifier___Builder = ___VARIABLE_productName:identifier___Builder(container: container)

    return RouterView { router in
        ___VARIABLE_camelCasedProductName:identifier___Builder.build___VARIABLE_productName:identifier___View(router: router)
    }
    .previewEnvironment()
}
