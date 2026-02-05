//
//  NewFeatureView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI

struct NewFeatureView: View {

    @State var viewModel: NewFeatureViewModel

    var body: some View {
        Text("NewFeature View")
            .navigationTitle("NewFeature")
            .screenAppearAnalytics(name: "NewFeatureView")
    }
}

#Preview {
    let container = DevPreview.shared.container
    let ___VARIABLE_camelCasedProductName:identifier___Builder = NewFeatureBuilder(container: container)

    return RouterView { router in
        ___VARIABLE_camelCasedProductName:identifier___Builder.buildNewFeatureView(router: router)
    }
    .previewEnvironment()
}
