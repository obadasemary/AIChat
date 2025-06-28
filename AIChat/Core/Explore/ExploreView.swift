//
//  ExploreView.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 07.04.2025.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    @Environment(PushManager.self) private var pushManager
    
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true
    
    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = false
    @State private var showNotificationButton: Bool = false
    @State private var showPushNotificationModal: Bool = false
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
            return true
        #else
            return false
        #endif
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    if isLoadingFeatured || isLoadingPopular {
                        loadingIndicator
                    } else {
                        contentUnavailableView
                    }
                }
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                if !popularAvatars.isEmpty {
                    categoriesSection
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if showNotificationButton {
                        pushNotificationButton
                    }
                }
            }
            .sheet(isPresented: $showDevSettings) {
                DevSettingsView()
            }
            .navigationDestinationForCoreModule(path: $path)
            .showModal(showModal: $showPushNotificationModal) {
                pushNotificationModal
            }
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
            .refreshable {
                await refreshAvatars()
            }
            .task {
                await handleShowPushNotificationButton()
            }
            .onFirstAppear {
                schedulePushNotifications()
            }
        }
    }
}

// MARK: - Load
private extension ExploreView {
    
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
}

// MARK: - SectionViews
private extension ExploreView {
    
    var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 200)
            .removeListRowFormatting()
    }
    
    var contentUnavailableView: some View {
        ContentUnavailableView(
            "No Connection",
            systemImage: "wifi.slash",
            description: Text("Please check your internet connection and try again later.")
        )
        .padding(.vertical, 200)
        .removeListRowFormatting()
    }
    
    var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvaterSelected(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured Avatars")
        }
    }
    
    var categoriesSection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars
                                .last(where: { $0.characterOption == category })?
                                .profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    onCategorySelected(
                                        category: category,
                                        imageName: imageName
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(height: 140)
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    onAvaterSelected(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    var devSettingsButton: some View {
        HStack {
            Image(systemName:"rectangle.portrait.and.arrow.forward")
            Text("Dev 🤫")
        }
        .badgeButton()
        .anyButton(.press) {
            onDevSettingsButtonTapped()
        }
    }
    
    var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                onPushNotificationButtonTapped()
            }
    }
    
    var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Push Notifications?",
            subtitle: "We'll send you updates about new features and improvements",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                onEnablePushNotificationTapped()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                onCancelPushNotificationTapped()
            }
        )
    }
}

// MARK: - Action
private extension ExploreView {
    
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
private extension ExploreView {
    
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
            case .categoryPressed(category: let category):
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
            case .loadPopularAvatarsFail, .loadFeaturedAvatarsFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}

#Preview("Mock Has Data") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: MockAvatarService()
            )
        )
        .previewEnvironment()
}

#Preview("Mock No Data") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(avatars: [])
            )
        )
        .previewEnvironment()
}

#Preview("Mock Slow Loading") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: MockAvatarService(delay: 2)
            )
        )
        .previewEnvironment()
}

#Preview("Remote Service") {
    ExploreView()
        .environment(
            AvatarManager(
                remoteService: FirebaseAvatarService(
                    firebaseImageUploadServiceProtocol: FirebaseImageUploadService()
                )
            )
        )
        .previewEnvironment()
}
