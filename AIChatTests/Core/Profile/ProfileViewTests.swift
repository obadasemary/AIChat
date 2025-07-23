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

        let container = DependencyContainer()
        
        let authManager = AuthManager(service: MockAuthService())
        
        let mockUser = UserModel.mock
        let userManager = UserManager(
            services: MockUserServices(currentUser: mockUser)
        )
        
        let avatarManager = AvatarManager(remoteService: MockAvatarService())
        let mockLogService = MockLogService()
        let logManager = LogManager(services: [mockLogService])
        
        container.register(AuthManager.self) {  authManager }
        container.register(UserManager.self) {  userManager }
        container.register(AvatarManager.self) {  avatarManager }
        container.register(LogManager.self) {  logManager }
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.currentUser?.userId == mockUser.userId)
        #expect(
            mockLogService.trackedEvents
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
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        await viewModel.loadData()
        
        // Then
        #expect(viewModel.myAvatars.count == mockAvatars.count)
        #expect(viewModel.isLoading == false)
        #expect(
            mockLogService.trackedEvents
                .contains {
                    $0.eventName == ProfileViewModel
                        .Event
                        .loadAvatarsSuccess(count: mockAvatars.count)
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
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
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
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        viewModel.onSettingsButtonPressed()
        
        // Then
        #expect(viewModel.showSettingsView == true)
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
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        viewModel.onNewAvatarButtonPressed()
        
        // Then
        #expect(viewModel.showCreateAvatarView == true)
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
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
        // When
        let avatar = AvatarModel.mock
        viewModel.onAvatarSelected(avatar: avatar)
        
        // Then
        #expect(viewModel.path.first == .chat(avatarId: avatar.id, chat: nil))
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
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
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
        
        // Given
        let viewModel = ProfileViewModel(container: container)
        
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
}
