//
//  ExploreViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.07.2025.
//

import Foundation

@Observable
@MainActor
final class ExplorePresenter {
    
    private let exploreInteractor: ExploreInteractorProtocol
    private let router: ExploreRouterProtocol
    
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    private(set) var showNotificationButton: Bool = false
    
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
            return true
        #else
            return false
        #endif
    }
    
    var categoryRowTest: CategoryRowTestOption {
        exploreInteractor.categoryRowTest
    }
    
    init(
        exploreInteractor: ExploreInteractorProtocol,
        router: ExploreRouterProtocol
    ) {
        self.exploreInteractor = exploreInteractor
        self.router = router
    }
}

// MARK: - Load

extension ExplorePresenter {
    
    func loadFeaturedAvatars(force: Bool = false) async {
        guard featuredAvatars.isEmpty || force else { return }
        exploreInteractor.trackEvent(event: Event.loadFeaturedAvatarsStart)
        do {
            featuredAvatars = try await exploreInteractor.getFeaturedAvatars()
            exploreInteractor
                .trackEvent(
                    event: Event.loadFeaturedAvatarsSuccess(
                        count: featuredAvatars.count
                    )
                )
        } catch {
            exploreInteractor
                .trackEvent(
                    event: Event.loadFeaturedAvatarsFail(
                        error: error
                    )
                )
        }
        
        isLoadingFeatured = false
    }
    
    func loadPopularAvatars(force: Bool = false) async {
        guard popularAvatars.isEmpty || force else {
            return
        }
        exploreInteractor.trackEvent(event: Event.loadPopularAvatarsStart)
        
        do {
            popularAvatars = try await exploreInteractor.getPopularAvatars()
            exploreInteractor
                .trackEvent(
                    event: Event.loadPopularAvatarsSuccess(
                        count: popularAvatars.count
                    )
                )
        } catch {
            exploreInteractor
                .trackEvent(
                    event: Event.loadPopularAvatarsFail(
                        error: error
                    )
                )
        }
        
        isLoadingPopular = false
    }
    
    func refreshAvatars() async {
        async let featuredAvatars: () = loadFeaturedAvatars(force: true)
        async let popularAvatars: () = loadPopularAvatars(force: true)
        _ = await (featuredAvatars, popularAvatars)
    }
    
    func handleShowPushNotificationButton() async {
        showNotificationButton = await exploreInteractor.canRequestAuthorization()
    }
    
    func schedulePushNotifications() {
        exploreInteractor.schedulePushNotificationForTheNextWeek()
    }
    
    func handleDeepLink(_ url: URL) {
        exploreInteractor.trackEvent(event: Event.deepLinkStart)
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            exploreInteractor.trackEvent(event: Event.deepLinkNoQueryItems)
            return
        }
        
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImage
                
                let delegate = CategoryListDelegate(
                    category: category,
                    imageName: imageName
                )
                router.showCategoryListView(delegate: delegate)
                
                exploreInteractor.trackEvent(event: Event.deepLinkCategory(category: category))
            }
            return
        }
        
        exploreInteractor.trackEvent(event: Event.deepLinkUnknown)
    }
    
    func showCreateAccountScreenIfNeeded() {
        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .seconds(1))
            
            guard
                self.exploreInteractor.auth?.isAnonymous == true &&
                    self.exploreInteractor.createAccountTest == true
            else {
                return
            }
            
            self.router
                .showCreateAccountView(
                    delegate: CreateAccountDelegate(),
                    onDisappear: nil
                )
        }
    }
}

// MARK: - Action
extension ExplorePresenter {
    
    func onDevSettingsButtonTapped() {
        exploreInteractor
            .trackEvent(
                event: Event.devSettingsPressed
            )
        router.showDevSettingsView()
    }
    
    func onPushNotificationButtonTapped() {
        
        func onEnablePushNotificationTapped() {
            router.dismissModal()
            Task { [weak self] in
                guard let self else { return }
                let isAuthorized = try await self.exploreInteractor.reuestAuthorization()
                self.exploreInteractor
                    .trackEvent(
                        event: Event
                            .pushNotificationEnabled(isAuthorized: isAuthorized)
                    )
                await self.handleShowPushNotificationButton()
            }
        }
        
        func onCancelPushNotificationTapped() {
            router.dismissModal()
            exploreInteractor
                .trackEvent(
                    event: Event.pushNotificationCancel
                )
        }
        
        exploreInteractor
            .trackEvent(
                event: Event.pushNotificationStart
            )
        router
            .showPushNotificationModal(
                onEnablePressed: {
                    onEnablePushNotificationTapped()
                },
                onCancelPressed: {
                    onCancelPushNotificationTapped()
                }
            )
    }
    
    
    
    func onAvaterSelected(avatar: AvatarModel) {
        exploreInteractor
            .trackEvent(
                event: Event.avatarPressed(
                    avatar: avatar
                )
            )
        let chatDelegate = ChatDelegate(avatarId: avatar.avatarId, chat: nil)
        router.showChatView(delegate: chatDelegate)
    }
    
    func onCategorySelected(
        category: CharacterOption,
        imageName: String
    ) {
        exploreInteractor
            .trackEvent(
                event: Event.categoryPressed(
                    category: category
                )
            )
        let categoryListDelegate = CategoryListDelegate(
            category: category,
            imageName: imageName
        )
        router.showCategoryListView(delegate: categoryListDelegate)
    }
    
    func onLogoutButtonPressed() {
        if (exploreInteractor.auth != nil) {
            try? exploreInteractor.signOut()
        }
        exploreInteractor.updateAppState(showTabBarView: false)
    }
}

// MARK: - Event
private extension ExplorePresenter {
    
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case pushNotificationStart
        case pushNotificationEnabled(isAuthorized: Bool)
        case pushNotificationCancel
        case deepLinkStart
        case deepLinkNoQueryItems
        case deepLinkCategory(category: CharacterOption)
        case deepLinkUnknown

        var eventName: String {
            switch self {
            case .devSettingsPressed: "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed: "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarsStart: "ExploreView_LoadFeaturedAvatars_Start"
            case .loadFeaturedAvatarsSuccess: "ExploreView_LoadFeaturedAvatars_Success"
            case .loadFeaturedAvatarsFail: "ExploreView_LoadFeaturedAvatars_Fail"
            case .loadPopularAvatarsStart: "ExploreView_LoadPopularAvatars_Start"
            case .loadPopularAvatarsSuccess: "ExploreView_LoadPopularAvatars_Success"
            case .loadPopularAvatarsFail: "ExploreView_LoadPopularAvatars_Fail"
            case .avatarPressed: "ExploreView_Avatar_Pressed"
            case .categoryPressed: "ExploreView_Category_Pressed"
            case .pushNotificationStart: "ExploreView_PushNotification_Start"
            case .pushNotificationEnabled: "ExploreView_PushNotification_Enabled"
            case .pushNotificationCancel: "ExploreView_PushNotification_Cancel"
            case .deepLinkStart: "ExploreView_DeepLink_Start"
            case .deepLinkNoQueryItems: "ExploreView_DeepLink_NoQueryItems"
            case .deepLinkCategory: "ExploreView_DeepLink_Category"
            case .deepLinkUnknown: "ExploreView_DeepLink_Unknown"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadPopularAvatarsSuccess(count: let count), .loadFeaturedAvatarsSuccess(count: let count):
                [
                    "avatars_count": count
                ]
            case .loadPopularAvatarsFail(error: let error), .loadFeaturedAvatarsFail(error: let error):
                error.eventParameters
            case .avatarPressed(avatar: let avatar):
                avatar.eventParameters
            case .categoryPressed(category: let category),
                    .deepLinkCategory(category: let category):
                [
                    "category": category.rawValue
                ]
            case .pushNotificationEnabled(isAuthorized: let isAuthorized):
                [
                    "is_authorized": isAuthorized
                ]
            default:
                nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadPopularAvatarsFail, .loadFeaturedAvatarsFail, .deepLinkUnknown:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
