//
//  ExploreViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.07.2025.
//

import Foundation

@Observable
@MainActor
final class ExploreViewModel {
    
    private let exploreUseCase: ExploreUseCaseProtocol
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
        exploreUseCase.categoryRowTest
    }
    
    init(
        exploreUseCase: ExploreUseCaseProtocol,
        router: ExploreRouterProtocol
    ) {
        self.exploreUseCase = exploreUseCase
        self.router = router
    }
}

// MARK: - Load

extension ExploreViewModel {
    
    func loadFeaturedAvatars(force: Bool = false) async {
        guard featuredAvatars.isEmpty || force else { return }
        exploreUseCase.trackEvent(event: Event.loadFeaturedAvatarsStart)
        do {
            featuredAvatars = try await exploreUseCase.getFeaturedAvatars()
            exploreUseCase
                .trackEvent(
                    event: Event.loadFeaturedAvatarsSuccess(
                        count: featuredAvatars.count
                    )
                )
        } catch {
            exploreUseCase
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
        exploreUseCase.trackEvent(event: Event.loadPopularAvatarsStart)
        
        do {
            popularAvatars = try await exploreUseCase.getPopularAvatars()
            exploreUseCase
                .trackEvent(
                    event: Event.loadPopularAvatarsSuccess(
                        count: popularAvatars.count
                    )
                )
        } catch {
            exploreUseCase
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
        showNotificationButton = await exploreUseCase.canRequestAuthorization()
    }
    
    func schedulePushNotifications() {
        exploreUseCase.schedulePushNotificationForTheNextWeek()
    }
    
    func handleDeepLink(_ url: URL) {
        exploreUseCase.trackEvent(event: Event.deepLinkStart)
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            exploreUseCase.trackEvent(event: Event.deepLinkNoQueryItems)
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
                
                exploreUseCase.trackEvent(event: Event.deepLinkCategory(category: category))
            }
            return
        }
        
        exploreUseCase.trackEvent(event: Event.deepLinkUnknown)
    }
    
    func showCreateAccountScreenIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            guard
                exploreUseCase.auth?.isAnonymous == true &&
                    exploreUseCase.createAccountTest == true
            else {
                return
            }
            
            router
                .showCreateAccountView(
                    delegate: CreateAccountDelegate(),
                    onDisappear: nil
                )
        }
    }
}

// MARK: - Action
extension ExploreViewModel {
    
    func onDevSettingsButtonTapped() {
        exploreUseCase
            .trackEvent(
                event: Event.devSettingsPressed
            )
        router.showDevSettingsView()
    }
    
    func onPushNotificationButtonTapped() {
        
        func onEnablePushNotificationTapped() {
            router.dismissModal()
            Task {
                let isAuthorized = try await exploreUseCase.reuestAuthorization()
                exploreUseCase
                    .trackEvent(
                        event: Event
                            .pushNotificationEnabled(isAuthorized: isAuthorized)
                    )
                await handleShowPushNotificationButton()
            }
        }
        
        func onCancelPushNotificationTapped() {
            router.dismissModal()
            exploreUseCase
                .trackEvent(
                    event: Event.pushNotificationCancel
                )
        }
        
        exploreUseCase
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
        exploreUseCase
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
        exploreUseCase
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
        if (exploreUseCase.auth != nil) {
            try? exploreUseCase.signOut()
        }
        exploreUseCase.updateAppState(showTabBarView: false)
    }
}

// MARK: - Event
private extension ExploreViewModel {
    
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
