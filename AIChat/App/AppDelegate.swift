//
//  AppDelegate.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 15.06.2025.
//

import Foundation
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: Dependencies!
    
//    var builder: CoreBuilder!
    
    var appBuilder: AppBuilder!
    var welcomeBuilder: WelcomeBuilder!
    var onboardingIntroBuilder: OnboardingIntroBuilder!
    var onboardingCommunityBuilder: OnboardingCommunityBuilder!
    var onboardingColorBuilder: OnboardingColorBuilder!
    var onboardingCompletedBuilder: OnboardingCompletedBuilder!
    
    var tabBarBuilder: TabBarBuilder!
    var exploreBuilder: ExploreBuilder!
    var categoryListBuilder: CategoryListBuilder!
    var devSettingsBuilder: DevSettingsBuilder!
    var createAccountBuilder: CreateAccountBuilder!
    
    var chatsBuilder: ChatsBuilder!
    var chatRowCellBuilder: ChatRowCellBuilder!
    var chatBuilder: ChatBuilder!

    var paywallBuilder: PaywallBuilder!

    var newsFeedBuilder: NewsFeedBuilder!
    var bookmarksBuilder: BookmarksBuilder!

    var profileBuilder: ProfileBuilder!
    var settingsBuilder: SettingsBuilder!
    var createAvatarBuilder: CreateAvatarBuilder!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        
        var config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        if Utilities.isUITesting {
            let isSignIn = ProcessInfo
                .processInfo
                .arguments
                .contains("SIGNED_IN_TEST")
            config = .mock(isSignedIn: isSignIn)
        }
        
        config.configureFirebase()
        dependencies = Dependencies(configuration: config)
        
//        builder = CoreBuilder(container: dependencies.container)
        
        appBuilder = AppBuilder(container: dependencies.container)
        welcomeBuilder = WelcomeBuilder(container: dependencies.container)
        onboardingIntroBuilder = OnboardingIntroBuilder(container: dependencies.container)
        onboardingCommunityBuilder = OnboardingCommunityBuilder(container: dependencies.container)
        onboardingColorBuilder = OnboardingColorBuilder(container: dependencies.container)
        onboardingCompletedBuilder = OnboardingCompletedBuilder(container: dependencies.container)
        
        tabBarBuilder = TabBarBuilder(container: dependencies.container)
        exploreBuilder = ExploreBuilder(
            container: dependencies.container
//            ,
//            devSettingsBuilder: DevSettingsBuilder(container: DevPreview.shared.container),
//            createAccountBuilder: CreateAccountBuilder(container: DevPreview.shared.container)
        )
        categoryListBuilder = CategoryListBuilder(container: dependencies.container)
        devSettingsBuilder = DevSettingsBuilder(container: dependencies.container)
        createAccountBuilder = CreateAccountBuilder(container: dependencies.container)
        
        chatsBuilder = ChatsBuilder(container: dependencies.container)
        chatRowCellBuilder = ChatRowCellBuilder(container: dependencies.container)
        chatBuilder = ChatBuilder(container: dependencies.container)

        paywallBuilder = PaywallBuilder(container: dependencies.container)

        newsFeedBuilder = NewsFeedBuilder(container: dependencies.container)
        bookmarksBuilder = BookmarksBuilder(container: dependencies.container)

        profileBuilder = ProfileBuilder(container: dependencies.container)
        settingsBuilder = SettingsBuilder(container: dependencies.container)
        createAvatarBuilder = CreateAvatarBuilder(container: dependencies.container)

        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
