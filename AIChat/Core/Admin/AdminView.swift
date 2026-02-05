//
//  AdminView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 05.02.2026.
//

import SwiftUI

struct AdminView: View {

    @State var viewModel: AdminViewModel

    var body: some View {
        Text("Admin View")
            .navigationTitle("Admin")
            .screenAppearAnalytics(name: "AdminView")
    }
}

#Preview {
    let container = DevPreview.shared.container
    let adminBuilder = AdminBuilder(container: container)

    return RouterView { router in
        adminBuilder.buildAdminView(router: router)
    }
    .previewEnvironment()
}
