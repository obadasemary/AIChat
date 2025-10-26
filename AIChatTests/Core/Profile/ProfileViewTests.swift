//
//  ProfileViewTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 23.07.2025.
//

import Testing
import Foundation
@testable import AIChat

@MainActor
struct ProfileViewTests {

    @Test("LoadData does set current user")
    func testLoadDataDoesSetCurrentUser() async throws {

//        let container = DependencyContainer()
//        
//        let authManager = AuthManager(service: MockAuthService())
//        
//        let mockUser = UserModel.mock
//        let userManager = UserManager(
//            services: MockUserServices(currentUser: mockUser)
//        )
//        
//        let avatarManager = AvatarManager(remoteService: MockAvatarService())
//        
//        let mockLogService = MockLogService()
//        let logManager = LogManager(services: [mockLogService])
//        
//        container.register(AuthManager.self) {  authManager }
//        container.register(UserManager.self) {  userManager }
//        container.register(AvatarManager.self) {  avatarManager }
//        container.register(LogManager.self) {  logManager }
        
        // Given
        let interactore = MockProfileInteractor()
        let profileRouter = MockProfileRouter()
        let viewModel = ProfileViewModel(
            profileUseCase: interactore,
            router: profileRouter
        )
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.currentUser?.userId == interactore.user.userId)
        #expect(
            interactore.logger.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .loadAvatarsStart
                        .eventName
                }
        )
    }
    
    @Test("LoadData does succeed and user avatars are loaded")
    func testLoadDataDoesSucceedAndAvatarsAreSet() async throws {

//        let container = DependencyContainer()
//        
//        let mockAuthUser = UserAuthInfo.mock()
//        let authManager = AuthManager(
//            service: MockAuthService(currentUser: mockAuthUser)
//        )
//        
//        let mockUser = UserModel.mock
//        let userManager = UserManager(
//            services: MockUserServices(currentUser: mockUser)
//        )
//        
//        let mockAvatars = AvatarModel.mocks
//        let avatarManager = AvatarManager(
//            remoteService: MockAvatarService(avatars: mockAvatars)
//        )
//        
//        let mockLogService = MockLogService()
//        let logManager = LogManager(services: [mockLogService])
//        
//        container.register(AuthManager.self) {  authManager }
//        container.register(UserManager.self) {  userManager }
//        container.register(AvatarManager.self) {  avatarManager }
//        container.register(LogManager.self) {  logManager }
        
        // Given
//        let viewModel = ProfileViewModel(
//            interactor: ProdProfileInteractor(container: container)
//        )
//        let interactore = MockProfileInteractor()
        let user = UserModel.mock
        let avatars = AvatarModel.mocks
        var events: [LoggableEvent] = []
        
        let interactore = AnyProfileInteractor(
            currentUser: user,
            getAuthId: {
                user.userId
            },
            getAvatarsForAuthor: { _ in
                avatars
            },
            removeAuthorIdFromAvatar: { _ in
                
            },
            trackEvent: { event in
                events.append(event)
            }
        )
        
        let profileRouter = MockProfileRouter()
        let viewModel = ProfileViewModel(
            profileUseCase: interactore,
            router: profileRouter
        )
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.myAvatars.count == avatars.count)
        #expect(viewModel.isLoading == false)
        #expect(
            events
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .loadAvatarsSuccess(count: 0)
                        .eventName
                }
        )
    }
    
    @Test("LoadData does fail")
    func testLoadDataDoesFail() async throws {

        let container = DependencyContainer()
        
        let authManager = AuthManager(
            service: MockAuthService(currentUser: nil)
        )
        
        let mockUser = UserModel.mock
        let userManager = UserManager(
            services: MockUserServices(currentUser: mockUser)
        )
        
        let mockAvatars = AvatarModel.mocks
        let avatarManager = AvatarManager(
            remoteService: MockAvatarService(avatars: mockAvatars)
        )
        
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self) {  authManager }
        container.register(UserManager.self) {  userManager }
        container.register(AvatarManager.self) {  avatarManager }
        container.register(LogManager.self) {  logManager }
        
        let profileRouter = MockProfileRouter()
        // Given
        let viewModel = ProfileViewModel(
            profileUseCase: ProfileUseCase(container: container),
            router: profileRouter
        )
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.isLoading == false)
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .loadAvatarsFail(error: URLError(.badURL))
                        .eventName
                }
        )
    }
    
    @Test("onSettingsButtonPressed")
    func testOnSettingsButtonPressed() async throws {

        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(remoteService: MockAvatarService())
        
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self) {  authManager }
        container.register(UserManager.self) {  userManager }
        container.register(AvatarManager.self) {  avatarManager }
        container.register(LogManager.self) {  logManager }
        
        let profileRouter = MockProfileRouter()
        // Given
        let viewModel = ProfileViewModel(
            profileUseCase: ProfileUseCase(container: container),
            router: profileRouter
        )
        
        // When
        viewModel.onSettingsButtonPressed()
        
        // Then
        #expect(profileRouter.showSettingsViewCalled == true)
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .settingsPressed
                        .eventName
                }
        )
    }
    
    @Test("Settings sign-in reloads profile data")
    func testSettingsSignInReloadsProfileData() async throws {
        let useCase = MutableProfileUseCase()
        useCase.currentUser = nil
        useCase.avatars = AvatarModel.mocks
        
        let router = MockProfileRouter()
        let viewModel = ProfileViewModel(
            profileUseCase: useCase,
            router: router
        )
        
        viewModel.onSettingsButtonPressed()
        
        #expect(router.showSettingsViewCalled == true)
        #expect(viewModel.myAvatars.isEmpty)
        
        useCase.currentUser = UserModel.mock
        router.settingsOnSignedInCallback?()
        
        try await Task.sleep(nanoseconds: 10_000_000)
        
        #expect(viewModel.currentUser?.userId == useCase.currentUser?.userId)
        #expect(viewModel.myAvatars.count == useCase.avatars.count)
    }
    
    
    @Test("onNewAvatarButtonPressed")
    func testOnNewAvatarButtonPressed() async throws {

        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(remoteService: MockAvatarService())
        
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self) {  authManager }
        container.register(UserManager.self) {  userManager }
        container.register(AvatarManager.self) {  avatarManager }
        container.register(LogManager.self) {  logManager }
        
        let profileRouter = MockProfileRouter()
        // Given
        let viewModel = ProfileViewModel(
            profileUseCase: ProfileUseCase(container: container),
            router: profileRouter
        )
        
        // When
        viewModel.onNewAvatarButtonPressed()
        
        // Then
        #expect(profileRouter.showCreateAvatarViewCalled == true)
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .newAvatarPressed
                        .eventName
                }
        )
    }
    
    @Test("onAvatarSelected")
    func testOnAvatarSelected() async throws {

        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService())
        let userManager = UserManager(services: MockUserServices())
        let avatarManager = AvatarManager(remoteService: MockAvatarService())
        
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self) {  authManager }
        container.register(UserManager.self) {  userManager }
        container.register(AvatarManager.self) {  avatarManager }
        container.register(LogManager.self) {  logManager }
        
        let profileRouter = MockProfileRouter()
        // Given
        let viewModel = ProfileViewModel(
            profileUseCase: ProfileUseCase(container: container),
            router: profileRouter
        )
        
        // When
        let avatar = AvatarModel.mock
        viewModel.onAvatarSelected(avatar: avatar)
        
        // Then
        #expect(profileRouter.showChatViewCalled == true)
        #expect(profileRouter.showChatViewDelegate?.avatarId == avatar.id)
        #expect(profileRouter.showChatViewDelegate?.chat == nil)
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .avatarPressed(avatar: avatar)
                        .eventName
                }
        )
    }
    
    @Test("onDeleteAvatar Does Succeed")
    func testOnDeleteAvatarSucceed() async throws {

        let container = DependencyContainer()
        
        let mockAuthUser = UserAuthInfo.mock()
        let authManager = AuthManager(
            service: MockAuthService(currentUser: mockAuthUser)
        )
        
        let mockUser = UserModel.mock
        let userManager = UserManager(
            services: MockUserServices(currentUser: mockUser)
        )
        
        let mockAvatars = AvatarModel.mocks
        let avatarManager = AvatarManager(
            remoteService: MockAvatarService(avatars: mockAvatars)
        )
        
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self) {  authManager }
        container.register(UserManager.self) {  userManager }
        container.register(AvatarManager.self) {  avatarManager }
        container.register(LogManager.self) {  logManager }
        
        let profileRouter = MockProfileRouter()
        // Given
        let viewModel = ProfileViewModel(
            profileUseCase: ProfileUseCase(container: container),
            router: profileRouter
        )
        
        // When
        await viewModel.loadData()
        viewModel.onDeleteAvatar(indexSet: IndexSet(integer: 0))
        try await Task.sleep(for: .seconds(1))
        
        // Then
        #expect(viewModel.myAvatars.count == (mockAvatars.count - 1))
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .deleteAvatarSuccess(avatar: mockAvatars[0])
                        .eventName
                }
        )
    }
    
    @Test("onDeleteAvatar Does Fail")
    func testOnDeleteAvatarFail() async throws {

        let container = DependencyContainer()
        
        let mockAuthUser = UserAuthInfo.mock()
        let authManager = AuthManager(
            service: MockAuthService(currentUser: mockAuthUser)
        )
        
        let mockUser = UserModel.mock
        let userManager = UserManager(
            services: MockUserServices(currentUser: mockUser)
        )
        
        let mockAvatars = AvatarModel.mocks
        let avatarManager = AvatarManager(
            remoteService: MockAvatarService(
                avatars: mockAvatars,
                showErrorForRemoveAuthorIdFromAvatar: true
            )
        )
        
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self) {  authManager }
        container.register(UserManager.self) {  userManager }
        container.register(AvatarManager.self) {  avatarManager }
        container.register(LogManager.self) {  logManager }
        
        let profileRouter = MockProfileRouter()
        // Given
        let viewModel = ProfileViewModel(
            profileUseCase: ProfileUseCase(container: container),
            router: profileRouter
        )
        
        // When
        await viewModel.loadData()
        viewModel.onDeleteAvatar(indexSet: IndexSet(integer: 0))
        try await Task.sleep(for: .seconds(1))
        
        // Then
        #expect(viewModel.myAvatars.count == mockAvatars.count)
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .deleteAvatarFail(error: URLError(.badURL))
                        .eventName
                }
        )
    }

    @MainActor
    private final class MutableProfileUseCase: ProfileUseCaseProtocol {
        var currentUser: UserModel?
        var avatars: [AvatarModel] = []
        var trackedEvents: [LoggableEvent] = []
        
        func getAuthId() throws -> String {
            guard let currentUser else {
                throw URLError(.userAuthenticationRequired)
            }
            return currentUser.userId
        }
        
        func getAvatarsForAuthor(userId: String) async throws -> [AvatarModel] {
            avatars
        }
        
        func removeAuthorIdFromAvatar(avatarId: String) async throws {}
        
        func trackEvent(event: any LoggableEvent) {
            trackedEvents.append(event)
        }
    }
}
