//
//  SettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @State var viewModel: SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                accountSection
                purchaseSection
                applicationSection
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .navigationTitle("Settings")
        .onAppear {
            viewModel.setAnonymousAccountStatus()
        }
        .screenAppearAnalytics(name: "SettingsView")
    }
}

// MARK: - SectionViews
private extension SettingsView {
    
    var accountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                if viewModel.isAnonymousUser {
                    SettingRowButton(
                        title: "Save & Backup Account",
                        textColor: .primary,
                        action: viewModel.onCreateAccountPressed,
                        isFirst: true,
                        isLast: false
                    )
                } else {
                    SettingRowButton(
                        title: "Sign Out",
                        textColor: .primary,
                        action: viewModel.onSignOutPressed,
                        isFirst: true,
                        isLast: false
                    )
                }
                
                Divider()
                    .padding(.leading, 16)
                
                SettingRowButton(
                    title: "Delete Account",
                    textColor: .red,
                    action: viewModel.onDeleteAccountPressed,
                    isFirst: false,
                    isLast: true
                )
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
        }
    }
    
    var purchaseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Purchase")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            
            HStack(spacing: 8) {
                Text("Account Status: \(viewModel.isPremium ? "PREMIUM" : "FREE")")
                
                Spacer(minLength: 0)
                
                Button {
                    viewModel.onManagePurchase()
                } label: {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
        }
    }
    
    var applicationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Application")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                SettingRowButton(
                    title: "Rate us on the App Store",
                    textColor: .blue,
                    action: viewModel.onRatingsPressed,
                    isFirst: true,
                    isLast: false
                )
                
                Divider()
                    .padding(.leading, 16)
                
                HStack(spacing: 8) {
                    Text("Version")
                    Spacer(minLength: 0)
                    Text(Utilities.appVersion ?? "")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color(uiColor: .systemBackground))
                
                Divider()
                    .padding(.leading, 16)
                
                HStack(spacing: 8) {
                    Text("Build Number")
                    Spacer(minLength: 0)
                    Text(Utilities.buildNumber ?? "")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(Color(uiColor: .systemBackground))
                
                Divider()
                    .padding(.leading, 16)
                
                SettingRowButton(
                    title: "About",
                    textColor: .primary,
                    action: viewModel.onAboutPressed,
                    isFirst: false,
                    isLast: false
                )
                
                Divider()
                    .padding(.leading, 16)
                
                SettingRowButton(
                    title: "Contact Support",
                    textColor: .blue,
                    action: viewModel.onContactUsPressed,
                    isFirst: false,
                    isLast: true
                )
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            
            Text("© \(Calendar.current.component(.year, from: Date()).description) Obada Inc.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }
}

private struct SettingRowButton: View {
    let title: String
    let textColor: Color
    let action: () -> Void
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
        }
        .buttonStyle(SettingRowButtonStyle())
    }
}

private struct SettingRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.accent.opacity(0.5) : Color(uiColor: .systemBackground))
            .animation(.smooth, value: configuration.isPressed)
    }
}


#Preview("No Auth") {
    let container = DevPreview.shared.container
    
    container.register(UserManager.self) {
        UserManager(services: MockUserServices(currentUser: nil))
    }
    
    container.register(AuthManager.self) {
        AuthManager(service: MockAuthService(currentUser: nil))
    }
    
    let settingsBuilder = SettingsBuilder(container: container)
    
    return RouterView { router in
        settingsBuilder.buildSettingsView(router: router)
    }
    .previewEnvironment(isSignedIn: false)
}

#Preview("Anonymous") {
    let container = DevPreview.shared.container
    
    container.register(UserManager.self) {
        UserManager(services: MockUserServices(currentUser: .mock))
    }
    
    container.register(AuthManager.self) {
        AuthManager(
            service: MockAuthService(
                currentUser: UserAuthInfo.mock(
                    isAnonymous: true
                )
            )
        )
    }
    
    let settingsBuilder = SettingsBuilder(container: container)
    
    return RouterView { router in
        settingsBuilder.buildSettingsView(router: router)
    }
    .previewEnvironment(isSignedIn: false)
}

#Preview("Not Anonymous") {
    let container = DevPreview.shared.container
    
    container.register(UserManager.self) {
        UserManager(services: MockUserServices(currentUser: .mock))
    }
    
    container.register(AuthManager.self) {
        AuthManager(
            service: MockAuthService(
                currentUser: UserAuthInfo.mock(
                    isAnonymous: false
                )
            )
        )
    }
    
    let settingsBuilder = SettingsBuilder(container: container)
    
    return RouterView { router in
        settingsBuilder.buildSettingsView(router: router)
    }
    .previewEnvironment(isSignedIn: false)
}
