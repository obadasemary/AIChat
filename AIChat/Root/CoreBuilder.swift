//
//  CoreBuilder.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 30.07.2025.
//

import SwiftUI
import SUIRouting

@Observable
@MainActor
class CoreBuilder {
    
    let container: DependencyContainer
    
    init(container: DependencyContainer) {
        self.container = container
    }
    
    func appView() -> some View {
        AppView(
            viewModel: AppViewModel(
                appViewUseCase: AppViewUseCase(
                    container: container
                )
            )
        )
    }
    
    func tabBarView() -> some View {
        TabBarView()
    }
    
    func welcomeView() -> some View {
        WelcomeView(
            viewModel: WelcomeViewModel(
                welcomeUseCase: WelcomeUseCase(container: container)
            )
        )
    }
    
    func onboardingIntroView(delegate: OnboardingIntroDelegate) -> some View {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                OnboardingIntroUseCase: OnboardingIntroUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }

    func onboardingCommunityView(delegate: OnboardingCommunityDelegate) -> some View {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(
                onboardingCommunityUseCase: OnboardingCommunityUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func onboardingColorView(delegate: OnboardingColorDelegate) -> some View {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(
                onboardingColorUseCase: OnboardingColorUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func onboardingCompletedView(delegate: OnboardingCompletedDelegate) -> some View {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(
                onboardingCompletedUseCase: OnboardingCompletedUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func exploreView(router: Router) -> some View {
        ExploreView(
            viewModel: ExploreViewModel(
                exploreUseCase: ExploreUseCase(container: container),
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
    }
    
    func createAccountView(
        delegate: CreateAccountDelegate = CreateAccountDelegate()
    ) -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(
                createAccountUseCase: CreateAccountUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func devSettingsView() -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(
                devSettingsUseCase: DevSettingsUseCase(container: container)
            )
        )
    }
    
    func categoryListView(delegate: CategoryListDelegate) -> some View {
        CategoryListView(
            viewModel: CategoryListViewModel(
                categoryListUseCase: CategoryListUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func chatsView() -> some View {
        ChatsView(
            viewModel: ChatsViewModel(
                chatsUseCase: ChatsUseCase(container: container)
            )
        )
    }
    
    func chatRowCellBuilderView(
        delegate: ChatRowCellDelegate = ChatRowCellDelegate()
    ) -> some View {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                chatRowCellUseCase: ChatRowCellUseCase(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func chatView(delegate: ChatDelegate) -> some View {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: container)
            ),
            delegate: delegate
        )
    }
    
    func paywallView() -> some View {
        PaywallView(
            viewModel: PaywallViewModel(
                paywallUseCase: PaywallUseCase(container: container)
            )
        )
    }
    
    func profileView() -> some View {
        ProfileView(
            viewModel: ProfileViewModel(
                profileUseCase: ProfileUseCase(container: container)
            )
        )
    }
    
    func settingsView() -> some View {
        SettingsView(
            viewModel: SettingsViewModel(
                settingsUseCase: SettingsUseCase(container: container)
            )
        )
    }
    
    func createAvatarView() -> some View {
        CreateAvatarView(
            viewModel: CreateAvatarViewModel(
                createAvatarUseCase: CreateAvatarUseCase(container: container)
            )
        )
    }
}
