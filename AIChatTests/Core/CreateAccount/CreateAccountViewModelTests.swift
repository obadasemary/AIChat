//
//  CreateAccountViewModelTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 17.02.2026.
//

import Testing
import AuthenticationServices
import GoogleSignIn
@testable import AIChat

@MainActor
struct CreateAccountViewModelTests {

    // MARK: - Initialization Tests

    @Test("ViewModel Initializes With No Alert")
    func testViewModelInitializesWithNoAlert() {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        #expect(viewModel.alert == nil)
    }

    // MARK: - Apple Sign In Tests

    @Test("Apple Sign In Success With New User Calls Delegate And Dismisses")
    func testAppleSignInSuccessWithNewUserCallsDelegateAndDismisses() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        var delegateCalledWithNewUser: Bool?
        var delegateModified = delegate
        delegateModified.onDidSignIn = { isNewUser in
            delegateCalledWithNewUser = isNewUser
        }

        mockUseCase.appleSignInResult = (user: .mock(), isNewUser: true)

        viewModel.onSignInWithAppleTapped(delegate: delegateModified)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(delegateCalledWithNewUser == true)
        #expect(mockRouter.dismissScreenCalled)
    }

    @Test("Apple Sign In Success With Existing User Calls Delegate And Dismisses")
    func testAppleSignInSuccessWithExistingUserCallsDelegateAndDismisses() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        var delegateCalledWithNewUser: Bool?
        var delegateModified = delegate
        delegateModified.onDidSignIn = { isNewUser in
            delegateCalledWithNewUser = isNewUser
        }

        mockUseCase.appleSignInResult = (user: .mock(), isNewUser: false)

        viewModel.onSignInWithAppleTapped(delegate: delegateModified)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(delegateCalledWithNewUser == false)
        #expect(mockRouter.dismissScreenCalled)
    }

    @Test("Apple Sign In Tracks Start Event")
    func testAppleSignInTracksStartEvent() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        mockUseCase.appleSignInResult = (user: .mock(), isNewUser: true)

        viewModel.onSignInWithAppleTapped(delegate: delegate)

        let startEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_AppleAuth_Start"
        }
        #expect(startEvents.count == 1)
    }

    @Test("Apple Sign In Success Tracks Success And Login Events")
    func testAppleSignInSuccessTracksSuccessAndLoginEvents() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        mockUseCase.appleSignInResult = (user: .mock(), isNewUser: true)

        viewModel.onSignInWithAppleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        let successEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_AppleAuth_Success"
        }
        let loginEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_AppleAuth_LoginSuccess"
        }

        #expect(successEvents.count == 1)
        #expect(loginEvents.count == 1)
    }

    @Test("Apple Sign In Cancellation Does Not Show Alert")
    func testAppleSignInCancellationDoesNotShowAlert() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        let cancelError = ASAuthorizationError(.canceled)
        mockUseCase.appleSignInError = cancelError

        viewModel.onSignInWithAppleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.alert == nil)
        #expect(!mockRouter.dismissScreenCalled)
    }

    @Test("Apple Sign In Generic Error Shows Alert")
    func testAppleSignInGenericErrorShowsAlert() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        let genericError = NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        mockUseCase.appleSignInError = genericError

        viewModel.onSignInWithAppleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.alert != nil)
        #expect(viewModel.alert?.title == "Error")
        #expect(!mockRouter.dismissScreenCalled)
    }

    @Test("Apple Sign In Account Exists Error Shows Custom Alert")
    func testAppleSignInAccountExistsErrorShowsCustomAlert() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        mockUseCase.appleSignInError = FirebaseAuthError.accountExistsWithDifferentProvider(email: "test@example.com")

        viewModel.onSignInWithAppleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.alert != nil)
        #expect(viewModel.alert?.title == "Account Already Exists")
        #expect(viewModel.alert?.subtitle?.contains("original sign-in method") == true)
        #expect(!mockRouter.dismissScreenCalled)
    }

    @Test("Apple Sign In Error Tracks Fail Event")
    func testAppleSignInErrorTracksFailEvent() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        let error = NSError(domain: "TestError", code: 999)
        mockUseCase.appleSignInError = error

        viewModel.onSignInWithAppleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        let failEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_AppleAuth_Fail"
        }
        #expect(failEvents.count == 1)
    }

    // MARK: - Google Sign In Tests

    @Test("Google Sign In Success With New User Calls Delegate And Dismisses")
    func testGoogleSignInSuccessWithNewUserCallsDelegateAndDismisses() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        var delegateCalledWithNewUser: Bool?
        var delegateModified = delegate
        delegateModified.onDidSignIn = { isNewUser in
            delegateCalledWithNewUser = isNewUser
        }

        mockUseCase.googleSignInResult = (user: .mock(), isNewUser: true)

        viewModel.onSignInWithGoogleTapped(delegate: delegateModified)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(delegateCalledWithNewUser == true)
        #expect(mockRouter.dismissScreenCalled)
    }

    @Test("Google Sign In Success With Existing User Calls Delegate And Dismisses")
    func testGoogleSignInSuccessWithExistingUserCallsDelegateAndDismisses() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        var delegateCalledWithNewUser: Bool?
        var delegateModified = delegate
        delegateModified.onDidSignIn = { isNewUser in
            delegateCalledWithNewUser = isNewUser
        }

        mockUseCase.googleSignInResult = (user: .mock(), isNewUser: false)

        viewModel.onSignInWithGoogleTapped(delegate: delegateModified)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(delegateCalledWithNewUser == false)
        #expect(mockRouter.dismissScreenCalled)
    }

    @Test("Google Sign In Tracks Start Event")
    func testGoogleSignInTracksStartEvent() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        mockUseCase.googleSignInResult = (user: .mock(), isNewUser: true)

        viewModel.onSignInWithGoogleTapped(delegate: delegate)

        let startEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_GoogleAuth_Start"
        }
        #expect(startEvents.count == 1)
    }

    @Test("Google Sign In Success Tracks Success And Login Events")
    func testGoogleSignInSuccessTracksSuccessAndLoginEvents() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        var delegateCalledWithNewUser: Bool?
        var delegateModified = delegate
        delegateModified.onDidSignIn = { isNewUser in
            delegateCalledWithNewUser = isNewUser
        }

        mockUseCase.googleSignInResult = (user: .mock(), isNewUser: true)

        viewModel.onSignInWithGoogleTapped(delegate: delegateModified)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        let successEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_GoogleAuth_Success"
        }
        let loginEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_GoogleAuth_LoginSuccess"
        }

        #expect(successEvents.count == 1)
        #expect(loginEvents.count == 1)
    }

    @Test("Google Sign In Cancellation Does Not Show Alert")
    func testGoogleSignInCancellationDoesNotShowAlert() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        let cancelError = GIDSignInError(.canceled)
        mockUseCase.googleSignInError = cancelError

        viewModel.onSignInWithGoogleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.alert == nil)
        #expect(!mockRouter.dismissScreenCalled)
    }

    @Test("Google Sign In Generic Error Shows Alert")
    func testGoogleSignInGenericErrorShowsAlert() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        let genericError = NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        mockUseCase.googleSignInError = genericError

        viewModel.onSignInWithGoogleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.alert != nil)
        #expect(viewModel.alert?.title == "Error")
        #expect(!mockRouter.dismissScreenCalled)
    }

    @Test("Google Sign In Account Exists Error Shows Custom Alert")
    func testGoogleSignInAccountExistsErrorShowsCustomAlert() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        mockUseCase.googleSignInError = FirebaseAuthError.accountExistsWithDifferentProvider(email: "test@example.com")

        viewModel.onSignInWithGoogleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.alert != nil)
        #expect(viewModel.alert?.title == "Account Already Exists")
        #expect(viewModel.alert?.subtitle?.contains("original sign-in method") == true)
        #expect(!mockRouter.dismissScreenCalled)
    }

    @Test("Google Sign In Error Tracks Fail Event")
    func testGoogleSignInErrorTracksFailEvent() async {
        let mockUseCase = MockCreateAccountUseCase()
        let mockRouter = MockCreateAccountRouter()

        let viewModel = CreateAccountViewModel(
            createAccountUseCase: mockUseCase,
            router: mockRouter
        )

        let delegate = CreateAccountDelegate()
        let error = NSError(domain: "TestError", code: 999)
        mockUseCase.googleSignInError = error

        viewModel.onSignInWithGoogleTapped(delegate: delegate)

        // Wait for async task to complete
        try? await Task.sleep(nanoseconds: 100_000_000)

        let failEvents = mockUseCase.trackedEvents.filter {
            $0.eventName == "CreateAccountView_GoogleAuth_Fail"
        }
        #expect(failEvents.count == 1)
    }
}

// MARK: - Mock CreateAccountUseCase

@MainActor
final class MockCreateAccountUseCase: CreateAccountUseCaseProtocol {

    var appleSignInResult: (user: UserAuthInfo, isNewUser: Bool)?
    var appleSignInError: Error?

    var googleSignInResult: (user: UserAuthInfo, isNewUser: Bool)?
    var googleSignInError: Error?

    var loginError: Error?

    var trackedEvents: [any LoggableEvent] = []

    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let error = appleSignInError {
            throw error
        }
        guard let result = appleSignInResult else {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No result configured"])
        }
        return result
    }

    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let error = googleSignInError {
            throw error
        }
        guard let result = googleSignInResult else {
            throw NSError(domain: "MockError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No result configured"])
        }
        return result
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        if let error = loginError {
            throw error
        }
    }

    func trackEvent(event: any LoggableEvent) {
        trackedEvents.append(event)
    }
}

// MARK: - Mock CreateAccountRouter

@MainActor
final class MockCreateAccountRouter: CreateAccountRouterProtocol {

    private(set) var dismissScreenCalled = false

    func dismissScreen() {
        dismissScreenCalled = true
    }
}
