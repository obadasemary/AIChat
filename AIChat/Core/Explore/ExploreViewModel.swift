//
//  ExploreViewModel.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.07.2025.
//

import Foundation

@Observable
@MainActor
class ExploreViewModel {
    
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var popularAvatars: [AvatarModel] = []
    
    private(set) var isLoadingFeatured: Bool = true
    private(set) var isLoadingPopular: Bool = true
    private(set) var showNotificationButton: Bool = false
    
    var showPushNotificationModal: Bool = false
    var showCreateAccountView: Bool = false
    var showDevSettings: Bool = false
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
            return true
        #else
            return false
        #endif
    }
    
    var categoryRowTest: CategoryRowTestOption {
        abTestManager.activeTests.categoryRowTest
    }
    
    var path: [NavigationPathOption] = []
    
    init(container: DIContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
    }
}

// MARK: - Load

extension ExploreViewModel {
    
    func loadFeaturedAvatars(force: Bool = false) async {
        guard featuredAvatars.isEmpty || force else { return }
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager
                .trackEvent(
                    event: Event.loadFeaturedAvatarsSuccess(
                        count: featuredAvatars.count
                    )
                )
        } catch {
            logManager
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
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)
        
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager
                .trackEvent(
                    event: Event.loadPopularAvatarsSuccess(
                        count: popularAvatars.count
                    )
                )
        } catch {
            logManager
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
        showNotificationButton = await pushManager.canRequestAuthorization()
    }
    
    func schedulePushNotifications() {
        pushManager.schedulePushNotificationForTheNextWeek()
    }
    
    func handleDeepLink(_ url: URL) {
        logManager.trackEvent(event: Event.deepLinkStart)
        
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
        else {
            logManager.trackEvent(event: Event.deepLinkNoQueryItems)
            return
        }
        
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value) {
                let imageName = popularAvatars.first(where: { $0.characterOption == category })?.profileImageName ?? Constants.randomImage
                path
                    .append(
                        .character(
                            category: category,
                            imageName: imageName
                        )
                    )
                logManager.trackEvent(event: Event.deepLinkCategory(category: category))
            }
            return
        }
        
        logManager.trackEvent(event: Event.deepLinkUnknown)
    }
    
    func showCreateAccountScreenIfNeeded() {
        Task {
            try? await Task.sleep(for: .seconds(1))
            
            guard
                authManager.auth?.isAnonymous == true &&
                abTestManager.activeTests.createAccountTest == true
            else {
                return
            }
            
            showCreateAccountView = true
        }
    }
}

// MARK: - Action
extension ExploreViewModel {
    
    func onDevSettingsButtonTapped() {
        showDevSettings = true
        logManager
            .trackEvent(
                event: Event.devSettingsPressed
            )
    }
    
    func onPushNotificationButtonTapped() {
        showPushNotificationModal = true
        logManager
            .trackEvent(
                event: Event.pushNotificationStart
            )
    }
    
    func onEnablePushNotificationTapped() {
        showPushNotificationModal = false
        
        Task {
            let isAuthorized = try await pushManager.reuestAuthorization()
            logManager
                .trackEvent(
                    event: Event
                        .pushNotificationEnabled(isAuthorized: isAuthorized)
                )
            await handleShowPushNotificationButton()
        }
    }
    
    func onCancelPushNotificationTapped() {
        showPushNotificationModal = false
        logManager
            .trackEvent(
                event: Event.pushNotificationCancel
            )
    }
    
    func onAvaterSelected(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager
            .trackEvent(
                event: Event.avatarPressed(
                    avatar: avatar
                )
            )
    }
    
    func onCategorySelected(
        category: CharacterOption,
        imageName: String
    ) {
        path
            .append(
                .character(
                    category: category,
                    imageName: imageName
                )
            )
        logManager
            .trackEvent(
                event: Event.categoryPressed(
                    category: category
                )
            )
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
//        case deepLinkAvatar(avatarId: String)
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
