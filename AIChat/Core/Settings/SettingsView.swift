//
//  SettingsView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(AppState.self) private var appState
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: SettingsViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchaseSection
                applicationSection
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .navigationTitle("Settings")
            .sheet(
                isPresented: $viewModel.showCreateAccountView,
                onDismiss: {
                    viewModel.setAnonymousAccountStatus()
                },
                content: {
                    CreateAccountView(
                        viewModel: CreateAccountViewModel(
                            createAccountUseCase: CreateAccountUseCase(container: container)
                        )
                    )
                    .presentationDetents([.medium])
                })
            .onAppear {
                viewModel.setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "SettingsView")
            .showModal(showModal: $viewModel.showRatingsModal) {
                ratingsModal
            }
        }
    }
}

// MARK: - SectionViews
private extension SettingsView {
    
    var ratingsModal: some View {
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your feedback!",
            primaryButtonTitle: "Yes",
            primaryButtonAction: {
                viewModel.onEnjoyingAppYesPressed()
            },
            secondaryButtonTitle: "No",
            secondaryButtonAction: {
                viewModel.onEnjoyingAppNoPressed()
            }
        )
    }
    
    var accountSection: some View {
        Section {
            if viewModel.isAnonymousUser {
                Text("Save & Backup Account")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onCreateAccountPressed()
                    }
                    .removeListRowFormatting()
            } else {
                Text("Sign Out")
                    .rowFormatting()
                    .anyButton(.highlight) {
                        viewModel.onSignOutPressed {
                            await dismissScreen()
                        }
                    }
                    .removeListRowFormatting()
            }
            
            Text("Delete Account")
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight) {
                    viewModel.onDeleteAccountPressed {
                        await dismissScreen()
                    }
                }
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    var purchaseSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account Status: \(viewModel.isPremium ? "PREMIUM" : "FREE")")
                
                Spacer(minLength: 0)
                
                if viewModel.isPremium {
                    Text("MANAGE")
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight) {
                
            }
            .disabled(!viewModel.isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchase")
        }
    }
    
    var applicationSection: some View {
        Section {
            Text("Rate us on the App Store")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    viewModel.onRatingsPressed()
                }
                .removeListRowFormatting()
            
            HStack(spacing: 8) {
                Text("Version")
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack(spacing: 8) {
                Text("Build Number")
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact Support")
                .foregroundStyle(.blue)
                .rowFormatting()
                .anyButton(.highlight) {
                    viewModel.onContactUsPressed()
                }
                .removeListRowFormatting()
        } header: {
            Text("Application")
        } footer: {
            Text("© \(Calendar.current.component(.year, from: Date()).description) Obada Inc.\n All rights reserved. \n Learn more at https://github.com/obadasemary")
                .foregroundStyle(.secondary)
                .baselineOffset(6)
        }
    }
}

// MARK: - Action
private extension SettingsView {
    
    func dismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
}

private struct RowFormattingViewModifier: ViewModifier {
    
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(colorScheme.backgroundPrimary)
    }
}

fileprivate extension View {
    func rowFormatting() -> some View {
        modifier(RowFormattingViewModifier())
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
    
    return SettingsView(
        viewModel: SettingsViewModel(
            settingsUseCase: SettingsUseCase(container: container)
        )
    )
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
    
    return SettingsView(
        viewModel: SettingsViewModel(
            settingsUseCase: SettingsUseCase(container: container)
        )
    )
    .previewEnvironment()
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
    
    return SettingsView(
        viewModel: SettingsViewModel(
            settingsUseCase: SettingsUseCase(container: container)
        )
    )
    .previewEnvironment()
}
