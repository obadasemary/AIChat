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
            presenter: AppPresenter(
                appViewInteractor: AppViewInteractor(
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
            presenter: WelcomePresenter(
                welcomeInteractor: WelcomeInteractor(container: container),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func onboardingIntroView(
        router: Router,
        delegate: OnboardingIntroDelegate
    ) -> some View {
        OnboardingIntroView(
            presenter: OnboardingIntroPresenter(
                OnboardingIntroInteractor: OnboardingIntroInteractor(
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
            presenter: OnboardingCommunityPresenter(
                onboardingCommunityInteractor: OnboardingCommunityInteractor(
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
            presenter: OnboardingColorPresenter(
                onboardingColorInteractor: OnboardingColorInteractor(
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
            presenter: OnboardingCompletedPresenter(
                onboardingCompletedInteractor: OnboardingCompletedInteractor(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func exploreView(router: Router) -> some View {
        ExploreView(
            presenter: ExplorePresenter(
                exploreInteractor: ExploreInteractor(container: container),
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
            presenter: CreateAccountPresenter(
                createAccountInteractor: CreateAccountInteractor(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func devSettingsView(router: Router) -> some View {
        DevSettingsView(
            presenter: DevSettingsPresenter(
                devSettingsInteractor: DevSettingsInteractor(container: container),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func categoryListView(
        router: Router,
        delegate: CategoryListDelegate
    ) -> some View {
        CategoryListView(
            presenter: CategoryListPresenter(
                categoryListInteractor: CategoryListInteractor(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func chatsView(router: Router) -> some View {
        ChatsView(
            presenter: ChatsPresenter(
                chatsInteractor: ChatsInteractor(container: container),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func chatRowCellBuilderView(
        delegate: ChatRowCellDelegate = ChatRowCellDelegate()
    ) -> some View {
        ChatRowCellViewBuilder(
            presenter: ChatRowCellPresenter(
                chatRowCellInteractor: ChatRowCellInteractor(
                    container: container
                )
            ),
            delegate: delegate
        )
    }
    
    func chatView(router: Router, delegate: ChatDelegate) -> some View {
        ChatView(
            presenter: ChatPresenter(
                chatInteractor: ChatInteractor(container: container),
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
    func paywallView(router: Router) -> some View {
        PaywallView(
            presenter: PaywallPresenter(
                paywallInteractor: PaywallInteractor(container: container),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
    func profileView(router: Router) -> some View {
        ProfileView(
            presenter: ProfilePresenter(
                profileInteractor: ProfileInteractor(container: container),
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
            presenter: SettingsPresenter(
                settingsInteractor: SettingsInteractor(container: container),
                router: CoreRouter(router: router, builder: self),
                onSignedIn: onSignedIn
            )
        )
    }
    
    func aboutView(router: Router) -> some View {
        AboutView(
            presenter: AboutPresenter(
                aboutInteractor: AboutInteractor(container: container),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func adminView(router: Router) -> some View {
        AdminView(
            viewModel: AdminViewModel(
                adminUseCase: AdminUseCase(container: container),
                router: AdminRouter(router: router)
            )
        )
    }
    
    func createAvatarView(router: Router) -> some View {
        CreateAvatarView(
            presenter: CreateAvatarPresenter(
                createAvatarInteractor: CreateAvatarInteractor(
                    container: container
                ),
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func newsFeedView(router: Router) -> some View {
        NewsFeedBuilder(container: container)
            .buildNewsFeedView(router: router)
    }

    func bookmarksView(router: Router) -> some View {
        BookmarksBuilder(container: container)
            .buildBookmarksView(router: router)
    }
}
