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
    
    func welcomeView(router: Router,) -> some View {
        WelcomeView(
            viewModel: WelcomeViewModel(
                welcomeUseCase: WelcomeUseCase(container: container),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func onboardingIntroView(
        router: Router,
        delegate: OnboardingIntroDelegate
    ) -> some View {
        OnboardingIntroView(
            viewModel: OnboardingIntroViewModel(
                OnboardingIntroUseCase: OnboardingIntroUseCase(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

    func onboardingCommunityView(
        router: Router,
        delegate: OnboardingCommunityDelegate
    ) -> some View {
        OnboardingCommunityView(
            viewModel: OnboardingCommunityViewModel(
                onboardingCommunityUseCase: OnboardingCommunityUseCase(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingColorView(
        router: Router,
        delegate: OnboardingColorDelegate
    ) -> some View {
        OnboardingColorView(
            viewModel: OnboardingColorViewModel(
                onboardingColorUseCase: OnboardingColorUseCase(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func onboardingCompletedView(
        router: Router,
        delegate: OnboardingCompletedDelegate
    ) -> some View {
        OnboardingCompletedView(
            viewModel: OnboardingCompletedViewModel(
                onboardingCompletedUseCase: OnboardingCompletedUseCase(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
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
        router: Router,
        delegate: CreateAccountDelegate = CreateAccountDelegate()
    ) -> some View {
        CreateAccountView(
            viewModel: CreateAccountViewModel(
                createAccountUseCase: CreateAccountUseCase(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func devSettingsView(router: Router) -> some View {
        DevSettingsView(
            viewModel: DevSettingsViewModel(
                devSettingsUseCase: DevSettingsUseCase(container: container),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func categoryListView(
        router: Router,
        delegate: CategoryListDelegate
    ) -> some View {
        CategoryListView(
            viewModel: CategoryListViewModel(
                categoryListUseCase: CategoryListUseCase(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func chatsView(router: Router) -> some View {
        ChatsView(
            viewModel: ChatsViewModel(
                chatsUseCase: ChatsUseCase(container: container),
                router: CoreRouter(router: router, builder: self)
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
    
    func chatView(router: Router, delegate: ChatDelegate) -> some View {
        ChatView(
            viewModel: ChatViewModel(
                chatUseCase: ChatUseCase(container: container),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func paywallView(router: Router) -> some View {
        PaywallView(
            viewModel: PaywallViewModel(
                paywallUseCase: PaywallUseCase(container: container)
            )
        )
    }
    
    func profileView(router: Router) -> some View {
        ProfileView(
            viewModel: ProfileViewModel(
                profileUseCase: ProfileUseCase(container: container),
                router: CoreRouter(
                    router: router,
                    builder: self
                )
            )
        )
    }
    
    func settingsView(
        router: Router,
        onSignedIn: @escaping () -> Void = {}
    ) -> some View {
        SettingsView(
            viewModel: SettingsViewModel(
                settingsUseCase: SettingsUseCase(container: container),
                router: CoreRouter(router: router, builder: self),
                onSignedIn: onSignedIn
            )
        )
    }
    
    func createAvatarView(router: Router) -> some View {
        CreateAvatarView(
            viewModel: CreateAvatarViewModel(
                createAvatarUseCase: CreateAvatarUseCase(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
