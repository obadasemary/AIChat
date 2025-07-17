//
//  AuthMangerTests.swift
//  AIChatTests
//
//  Created by Abdelrahman Mohamed on 16.07.2025.
//

import Testing
@testable import AIChat

struct AuthMangerTests {

    @Test("INitialization with Auth User")
    func testInitializationWithAuthUser() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = await MockAuthService(currentUser: mockUser)
        let authManager = await AuthManager(service: authService)
        
        await #expect(authManager.auth?.uid == mockUser.uid)
    }

    @Test("Sign In Anonymously")
    func testSignInAnonymously() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: true)
        let authService = await MockAuthService(currentUser: mockUser)
        let authManager = await AuthManager(service: authService)
        
        let result = try await authManager.signInAnonymously()
        
        #expect(result.user.isAnonymous == true)
        await #expect(authManager.auth?.isAnonymous == true)
    }
    
    @Test("Sign In with Apple")
    func testSignInWithApple() async throws {
        let authService = await MockAuthService()
        let authManager = await AuthManager(service: authService)
        
        let result = try await authManager.signInWithApple()
        
        #expect(result.user.isAnonymous == false)
    }
    
    @Test("Sign In with Google")
    func testSignInWithGooglee() async throws {
        let authService = await MockAuthService()
        let authManager = await AuthManager(service: authService)
        
        let result = try await authManager.signInWithGoogle()
        
        #expect(result.user.isAnonymous == false)
    }
    
    @Test("Sign Out")
    func testSignOut() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = await MockAuthService(currentUser: mockUser)
        let authManager = await AuthManager(service: authService)
        
        try await authManager.signOut()
        
        await #expect(authManager.auth?.uid == nil)
    }
    
    @Test("Delete Account")
    func testDeleteAccount() async throws {
        let mockUser = UserAuthInfo.mock(isAnonymous: false)
        let authService = await MockAuthService(currentUser: mockUser)
        let authManager = await AuthManager(service: authService)
        
        _ = try await authManager.deleteAccount()
        await #expect(authManager.auth == nil)
    }
}
